import React, { useEffect, useState, useMemo } from 'react';
import { loadStripe } from '@stripe/stripe-js';
import { Elements, PaymentElement, useStripe, useElements } from '@stripe/react-stripe-js';
import { useNavigate, Link } from 'react-router-dom';
import { supabase } from '@/lib/supabase';
import { clearCart, cartTotal, removeFromCart, updateQty } from '@/lib/cart';

import { useCart } from '@/hooks/useCart';
import { useAuth } from '@/contexts/AuthContext';
import { ArrowLeft, Trash2, Plus, Minus, ShieldCheck, MapPin } from 'lucide-react';
import { toast } from 'sonner';


const STRIPE_ACCOUNT_ID = 'acct_1TVoIwPiLedwFutb';
const stripePromise = loadStripe('pk_live_9eBOACiG83hSt0n4y7Kg9Exo', { stripeAccount: STRIPE_ACCOUNT_ID });

const US_STATES = ['AL','AK','AZ','AR','CA','CO','CT','DE','FL','GA','HI','ID','IL','IN','IA','KS','KY','LA','ME','MD','MA','MI','MN','MS','MO','MT','NE','NV','NH','NJ','NM','NY','NC','ND','OH','OK','OR','PA','RI','SC','SD','TN','TX','UT','VT','VA','WA','WV','WI','WY','DC'];

function PaymentForm({ onSuccess, processing, setProcessing }: any) {
  const stripe = useStripe();
  const elements = useElements();
  const [error, setError] = useState('');

  const submit = async (e: React.FormEvent) => {
    e.preventDefault();
    if (!stripe || !elements) return;
    setProcessing(true);
    setError('');
    const { error: err, paymentIntent } = await stripe.confirmPayment({
      elements,
      redirect: 'if_required',
    });
    if (err) {
      setError(err.message || 'Payment failed');
      setProcessing(false);
    } else if (paymentIntent?.status === 'succeeded') {
      await onSuccess(paymentIntent);
    } else {
      setProcessing(false);
    }
  };

  return (
    <form onSubmit={submit}>
      <PaymentElement />
      {error && <p className="text-red-600 mt-3 text-sm">{error}</p>}
      <button
        type="submit"
        disabled={!stripe || processing}
        className="w-full mt-6 bg-[#FF6B47] hover:bg-[#e55a37] text-white py-4 rounded-full font-bold text-lg shadow-xl disabled:opacity-60 transition-all"
      >
        {processing ? 'Processing...' : 'Pay Now'}
      </button>
    </form>
  );
}

const Checkout: React.FC = () => {
  const cart = useCart();
  const navigate = useNavigate();
  const { account } = useAuth();
  const [clientSecret, setClientSecret] = useState('');
  const [paymentError, setPaymentError] = useState('');
  const [processing, setProcessing] = useState(false);
  const [shipping] = useState(0);
  const [tax, setTax] = useState(0);
  const [savedAddresses, setSavedAddresses] = useState<any[]>([]);
  const [addr, setAddr] = useState({
    name: '', email: '', phone: '', address: '', city: '', state: 'CA', zip: '',
  });

  // Auto-fill from logged-in account and load saved addresses
  useEffect(() => {
    if (!account) return;
    setAddr(a => ({ ...a, email: account.email, name: account.name || a.name, phone: account.phone || a.phone }));
    supabase.from('customer_addresses').select('*').eq('account_id', account.id).then(({ data }) => {
      if (data && data.length > 0) {
        setSavedAddresses(data);
        const def = data.find(d => d.is_default) || data[0];
        setAddr(a => ({ ...a, name: def.name || a.name, address: def.address || '', city: def.city || '', state: def.state || a.state, zip: def.zip || '' }));
      }
    });
  }, [account]);


  const subtotal = useMemo(() => cartTotal(cart), [cart]);
  const total = subtotal + shipping + tax;

  // Calculate tax when state changes
  useEffect(() => {
    if (subtotal <= 0) { setTax(0); return; }
    supabase.functions.invoke('calculate-tax', {
      body: { state: addr.state, subtotal },
    }).then(({ data }) => {
      if (data?.success) setTax(data.taxCents || 0);
    });
  }, [addr.state, subtotal]);

  // Create payment intent
  useEffect(() => {
    if (total <= 0) return;
    setClientSecret('');
    setPaymentError('');
    supabase.functions.invoke('create-payment-intent', {
      body: { amount: total, currency: 'usd' },
    }).then(({ data, error }) => {
      if (error || !data?.clientSecret) {
        setPaymentError('Unable to initialize payment. Please try again.');
        return;
      }
      setClientSecret(data.clientSecret);
    });
  }, [total]);

  const handlePaymentSuccess = async (paymentIntent: any) => {
    try {
      const { data: customer } = await supabase
        .from('ecom_customers')
        .upsert({ email: addr.email, name: addr.name, phone: addr.phone, address: addr, account_id: account?.id || null }, { onConflict: 'email' })
        .select('id, email, name')
        .single();

      const { data: order } = await supabase
        .from('ecom_orders')
        .insert({
          customer_id: customer?.id,
          account_id: account?.id || null,
          status: 'paid',
          subtotal,
          tax,
          shipping,
          total,
          shipping_address: addr,
          stripe_payment_intent_id: paymentIntent.id,
        })
        .select('id')
        .single();

      if (order) {
        const items = cart.map(i => ({
          order_id: order.id,
          product_id: i.product_id,
          variant_id: i.variant_id || null,
          product_name: i.name,
          variant_title: i.variant_title || null,
          sku: i.sku || null,
          quantity: i.quantity,
          unit_price: i.price,
          total: i.price * i.quantity,
        }));
        await supabase.from('ecom_order_items').insert(items);

        // Send confirmation email
        try {
          await fetch('https://famous.ai/api/ecommerce/6a018525486a1600bdce72d0/send-confirmation', {
            method: 'POST',
            headers: { 'Content-Type': 'application/json' },
            body: JSON.stringify({
              orderId: order.id,
              customerEmail: addr.email,
              customerName: addr.name,
              orderItems: items,
              subtotal, shipping, tax, total,
              shippingAddress: addr,
            }),
          });
        } catch {}

        // CRM subscribe
        try {
          await fetch('https://famous.ai/api/crm/6a018525486a1600bdce72d0/subscribe', {
            method: 'POST',
            headers: { 'Content-Type': 'application/json' },
            body: JSON.stringify({
              email: addr.email,
              name: addr.name,
              source: 'checkout',
              tags: ['customer', 'purchaser'],
            }),
          });
        } catch {}

        clearCart();
        toast.success('Order placed! 🌸');
        navigate(`/order-confirmation/${order.id}`);
      }
    } catch (err: any) {
      toast.error('Order creation failed: ' + err.message);
      setProcessing(false);
    }
  };

  if (cart.length === 0) {
    return (
      <div className="min-h-screen bg-[#FFF8F0] flex flex-col items-center justify-center px-6">
        <h1 className="font-serif text-5xl font-bold text-[#2D6A4F] mb-4" style={{ fontFamily: 'Playfair Display, serif' }}>Your cart is empty</h1>
        <p className="text-[#2D6A4F]/70 mb-8">Start sipping by adding some juice to your cart.</p>
        <Link to="/" className="bg-[#FF6B47] text-white px-8 py-3 rounded-full font-semibold hover:bg-[#e55a37]">
          Browse Juices
        </Link>
      </div>
    );
  }

  const fmt = (c: number) => `$${(c / 100).toFixed(2)}`;
  const canPay = addr.name && addr.email && addr.address && addr.city && addr.state && addr.zip;

  return (
    <div className="min-h-screen bg-gradient-to-br from-[#FFF8F0] to-[#FFE8D6] py-12 px-6">
      <div className="max-w-6xl mx-auto">
        <Link to="/" className="inline-flex items-center gap-2 text-[#2D6A4F] hover:text-[#FF6B47] mb-6 font-medium">
          <ArrowLeft size={18} /> Back to shop
        </Link>

        <h1 className="text-5xl font-bold text-[#2D6A4F] mb-10" style={{ fontFamily: 'Playfair Display, serif' }}>
          Checkout
        </h1>

        <div className="grid lg:grid-cols-5 gap-8">
          {/* Left: forms */}
          <div className="lg:col-span-3 space-y-6">
            <div className="bg-white rounded-3xl shadow-lg p-8">
              <h2 className="text-2xl font-bold text-[#2D6A4F] mb-6" style={{ fontFamily: 'Playfair Display, serif' }}>
                Shipping Address
              </h2>

              {savedAddresses.length > 0 && (
                <div className="mb-6">
                  <div className="text-sm font-semibold text-[#2D6A4F] mb-2 flex items-center gap-1.5"><MapPin size={14} /> Saved addresses</div>
                  <div className="flex flex-wrap gap-2">
                    {savedAddresses.map((sa) => (
                      <button
                        key={sa.id}
                        type="button"
                        onClick={() => setAddr(a => ({ ...a, name: sa.name || a.name, address: sa.address || '', city: sa.city || '', state: sa.state || a.state, zip: sa.zip || '' }))}
                        className="px-3 py-1.5 rounded-full text-sm bg-[#FFF8F0] hover:bg-[#FF6B47] hover:text-white text-[#2D6A4F] border border-[#2D6A4F]/15 transition"
                      >
                        {sa.label || sa.city} {sa.is_default && '★'}
                      </button>
                    ))}
                  </div>
                </div>
              )}

              <div className="grid md:grid-cols-2 gap-4">
                <input className="md:col-span-2 px-4 py-3 rounded-xl border border-[#2D6A4F]/15 focus:border-[#FF6B47] outline-none" placeholder="Full name" value={addr.name} onChange={e => setAddr({...addr, name: e.target.value})} />
                <input className="px-4 py-3 rounded-xl border border-[#2D6A4F]/15 focus:border-[#FF6B47] outline-none" placeholder="Email" type="email" value={addr.email} onChange={e => setAddr({...addr, email: e.target.value})} />
                <input className="px-4 py-3 rounded-xl border border-[#2D6A4F]/15 focus:border-[#FF6B47] outline-none" placeholder="Phone" value={addr.phone} onChange={e => setAddr({...addr, phone: e.target.value})} />
                <input className="md:col-span-2 px-4 py-3 rounded-xl border border-[#2D6A4F]/15 focus:border-[#FF6B47] outline-none" placeholder="Street address" value={addr.address} onChange={e => setAddr({...addr, address: e.target.value})} />
                <input className="px-4 py-3 rounded-xl border border-[#2D6A4F]/15 focus:border-[#FF6B47] outline-none" placeholder="City" value={addr.city} onChange={e => setAddr({...addr, city: e.target.value})} />
                <select className="px-4 py-3 rounded-xl border border-[#2D6A4F]/15 focus:border-[#FF6B47] outline-none bg-white" value={addr.state} onChange={e => setAddr({...addr, state: e.target.value})}>
                  {US_STATES.map(s => <option key={s}>{s}</option>)}
                </select>
                <input className="px-4 py-3 rounded-xl border border-[#2D6A4F]/15 focus:border-[#FF6B47] outline-none" placeholder="ZIP" value={addr.zip} onChange={e => setAddr({...addr, zip: e.target.value})} />
              </div>
            </div>


            <div className="bg-white rounded-3xl shadow-lg p-8">
              <h2 className="text-2xl font-bold text-[#2D6A4F] mb-6 flex items-center gap-2" style={{ fontFamily: 'Playfair Display, serif' }}>
                <ShieldCheck size={24} className="text-[#2D6A4F]" />
                Payment
              </h2>
              {!canPay ? (
                <p className="text-[#2D6A4F]/70 bg-[#FFF8F0] p-4 rounded-xl">
                  Please fill in your shipping address to continue.
                </p>
              ) : paymentError ? (
                <p className="text-red-600 bg-red-50 p-4 rounded-xl">{paymentError}</p>
              ) : !clientSecret ? (
                <div className="text-[#2D6A4F]/70">Loading secure payment form...</div>
              ) : (
                <Elements stripe={stripePromise} options={{ clientSecret, appearance: { theme: 'stripe' } }}>
                  <PaymentForm onSuccess={handlePaymentSuccess} processing={processing} setProcessing={setProcessing} />
                </Elements>
              )}
            </div>
          </div>

          {/* Right: summary */}
          <div className="lg:col-span-2">
            <div className="bg-white rounded-3xl shadow-lg p-8 sticky top-6">
              <h2 className="text-2xl font-bold text-[#2D6A4F] mb-6" style={{ fontFamily: 'Playfair Display, serif' }}>
                Order Summary
              </h2>

              <div className="space-y-4 mb-6 max-h-80 overflow-y-auto pr-2">
                {cart.map(item => (
                  <div key={item.product_id} className="flex gap-3 pb-4 border-b border-[#2D6A4F]/5 last:border-0">
                    {item.image && <img src={item.image} alt={item.name} className="w-16 h-16 rounded-xl object-cover" />}
                    <div className="flex-1">
                      <div className="font-semibold text-[#2D6A4F]">{item.name}</div>
                      <div className="text-sm text-[#2D6A4F]/60">{fmt(item.price)} each</div>
                      <div className="flex items-center gap-2 mt-2">
                        <button onClick={() => updateQty(item.product_id, item.variant_id, item.quantity - 1)} className="w-7 h-7 rounded-full bg-[#FFF8F0] flex items-center justify-center text-[#2D6A4F] hover:bg-[#FF6B47] hover:text-white"><Minus size={14} /></button>
                        <span className="font-semibold w-6 text-center">{item.quantity}</span>
                        <button onClick={() => updateQty(item.product_id, item.variant_id, item.quantity + 1)} className="w-7 h-7 rounded-full bg-[#FFF8F0] flex items-center justify-center text-[#2D6A4F] hover:bg-[#FF6B47] hover:text-white"><Plus size={14} /></button>
                        <button onClick={() => removeFromCart(item.product_id, item.variant_id)} className="ml-auto text-red-500 hover:text-red-700"><Trash2 size={16} /></button>
                      </div>
                    </div>
                    <div className="font-bold text-[#2D6A4F]">{fmt(item.price * item.quantity)}</div>
                  </div>
                ))}
              </div>

              <div className="space-y-2 py-4 border-t border-[#2D6A4F]/10">
                <div className="flex justify-between text-[#2D6A4F]/80"><span>Subtotal</span><span>{fmt(subtotal)}</span></div>
                <div className="flex justify-between text-[#2D6A4F]/80"><span>Shipping</span><span className="text-[#2D6A4F] font-semibold">FREE</span></div>
                <div className="flex justify-between text-[#2D6A4F]/80"><span>Tax</span><span>{fmt(tax)}</span></div>
              </div>
              <div className="flex justify-between text-2xl font-bold text-[#2D6A4F] pt-4 border-t-2 border-[#2D6A4F]/10" style={{ fontFamily: 'Playfair Display, serif' }}>
                <span>Total</span><span>{fmt(total)}</span>
              </div>

              <div className="mt-6 p-4 bg-[#2D6A4F]/5 rounded-xl text-sm text-[#2D6A4F]/80 flex items-center gap-2">
                <ShieldCheck size={16} /> Secure checkout via FamousPay
              </div>
            </div>
          </div>
        </div>
      </div>
    </div>
  );
};

export default Checkout;
