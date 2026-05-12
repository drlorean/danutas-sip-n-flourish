import React, { useEffect, useState } from 'react';
import { useParams, Link } from 'react-router-dom';
import { supabase } from '@/lib/supabase';
import { CheckCircle2, Mail } from 'lucide-react';

const OrderConfirmation: React.FC = () => {
  const { id } = useParams();
  const [order, setOrder] = useState<any>(null);
  const [items, setItems] = useState<any[]>([]);

  useEffect(() => {
    if (!id) return;
    supabase.from('ecom_orders').select('*').eq('id', id).single().then(({ data }) => setOrder(data));
    supabase.from('ecom_order_items').select('*').eq('order_id', id).then(({ data }) => setItems(data || []));
  }, [id]);

  const fmt = (c: number) => `$${((c || 0) / 100).toFixed(2)}`;

  return (
    <div className="min-h-screen bg-gradient-to-br from-[#FFF8F0] to-[#FFE8D6] py-16 px-6">
      <div className="max-w-2xl mx-auto bg-white rounded-3xl shadow-2xl p-10 text-center">
        <div className="w-20 h-20 mx-auto rounded-full bg-[#2D6A4F]/10 flex items-center justify-center mb-6">
          <CheckCircle2 size={48} className="text-[#2D6A4F]" />
        </div>
        <h1 className="text-5xl font-bold text-[#2D6A4F] mb-3" style={{ fontFamily: 'Playfair Display, serif' }}>
          Thank You!
        </h1>
        <p className="text-lg text-[#2D6A4F]/70 mb-2">Your order has been placed and is being pressed fresh 🌸</p>
        {order && (
          <p className="text-sm text-[#2D6A4F]/60 mb-8">
            Order #{String(order.id).slice(0, 8).toUpperCase()}
          </p>
        )}

        {items.length > 0 && (
          <div className="text-left bg-[#FFF8F0] rounded-2xl p-6 mb-6">
            <h2 className="font-bold text-[#2D6A4F] mb-4">Your Order</h2>
            {items.map((it: any) => (
              <div key={it.id} className="flex justify-between py-2 text-[#2D6A4F]/80 border-b border-[#2D6A4F]/5 last:border-0">
                <span>{it.product_name} x {it.quantity}</span>
                <span className="font-semibold">{fmt(it.total)}</span>
              </div>
            ))}
            {order && (
              <div className="mt-4 pt-4 border-t-2 border-[#2D6A4F]/10 space-y-1 text-[#2D6A4F]/80">
                <div className="flex justify-between"><span>Subtotal</span><span>{fmt(order.subtotal)}</span></div>
                <div className="flex justify-between"><span>Shipping</span><span>FREE</span></div>
                <div className="flex justify-between"><span>Tax</span><span>{fmt(order.tax)}</span></div>
                <div className="flex justify-between font-bold text-[#2D6A4F] text-lg pt-2 border-t border-[#2D6A4F]/10">
                  <span>Total</span><span>{fmt(order.total)}</span>
                </div>
              </div>
            )}
          </div>
        )}

        <p className="text-[#2D6A4F]/70 mb-8 flex items-center justify-center gap-2">
          <Mail size={16} /> A confirmation email is on its way!
        </p>

        <Link to="/" className="inline-block bg-[#FF6B47] hover:bg-[#e55a37] text-white px-8 py-3 rounded-full font-semibold shadow-lg">
          Continue Shopping
        </Link>
      </div>
    </div>
  );
};

export default OrderConfirmation;
