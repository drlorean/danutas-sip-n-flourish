import React, { useState } from 'react';
import { MapPin, Mail, Phone, Send } from 'lucide-react';
import { toast } from 'sonner';

const juices = [
  'Sunrise Glow',
  'Green Goddess',
  'Berry Bliss',
  'Tropical Escape',
  'Citrus Rush',
  'Watermelon Wave',
];

const Order: React.FC = () => {
  const [form, setForm] = useState({
    name: '',
    email: '',
    phone: '',
    juice: juices[0],
    quantity: 1,
    method: 'delivery',
    notes: '',
  });
  const [loading, setLoading] = useState(false);

  const update = (k: string, v: any) => setForm({ ...form, [k]: v });

  const submit = async (e: React.FormEvent) => {
    e.preventDefault();
    if (!form.name || !form.email) {
      toast.error('Please fill in your name and email');
      return;
    }
    setLoading(true);
    try {
      await fetch('https://famous.ai/api/crm/6a018525486a1600bdce72d0/subscribe', {
        method: 'POST',
        headers: { 'Content-Type': 'application/json' },
        body: JSON.stringify({
          email: form.email,
          name: form.name,
          source: 'order-form',
          tags: ['order', 'juice-customer', form.juice.toLowerCase().replace(/\s+/g, '-')],
        }),
      });
    } catch {}
    setLoading(false);
    toast.success('Order received! 🌸', {
      description: `We'll be in touch shortly to confirm your ${form.quantity}x ${form.juice}.`,
    });
    setForm({ ...form, name: '', email: '', phone: '', notes: '', quantity: 1 });
  };

  return (
    <section id="order" className="py-24 px-6 bg-gradient-to-br from-[#FFE8D6] to-[#FFF8F0] relative overflow-hidden">
      <div className="absolute top-20 left-10 text-8xl opacity-10 select-none">🍊</div>
      <div className="absolute bottom-20 right-10 text-8xl opacity-10 select-none">🥭</div>

      <div className="max-w-6xl mx-auto grid lg:grid-cols-5 gap-10 relative">
        <div className="lg:col-span-2 flex flex-col justify-center">
          <div className="inline-flex w-fit items-center gap-2 text-[#FF6B47] font-semibold uppercase tracking-[0.2em] text-sm mb-4">
            Order Up
          </div>
          <h2 className="font-serif-display text-5xl md:text-6xl font-bold text-[#2D6A4F] mb-6 leading-tight">
            Ready to <span className="italic text-[#FF6B47]">Flourish?</span>
          </h2>
          <p className="text-lg text-[#2D6A4F]/70 mb-10 leading-relaxed">
            Place your order below and we'll press your juice fresh and deliver
            it the same day. Or DM us on Instagram for express requests.
          </p>

          <div className="space-y-5">
            <div className="flex items-start gap-4">
              <div className="w-12 h-12 rounded-full bg-[#FF6B47]/10 flex items-center justify-center flex-shrink-0">
                <MapPin className="text-[#FF6B47]" size={20} />
              </div>
              <div>
                <div className="font-bold text-[#2D6A4F]">Find Us</div>
                <div className="text-[#2D6A4F]/70">Local Pop-Up Markets & Events</div>
              </div>
            </div>
            <div className="flex items-start gap-4">
              <div className="w-12 h-12 rounded-full bg-[#FF6B47]/10 flex items-center justify-center flex-shrink-0">
                <Mail className="text-[#FF6B47]" size={20} />
              </div>
              <div>
                <div className="font-bold text-[#2D6A4F]">Email Us</div>
                <a href="mailto:hello@sipandflourish.com" className="text-[#2D6A4F]/70 hover:text-[#FF6B47]">hello@sipandflourish.com</a>
              </div>
            </div>
            <div className="flex items-start gap-4">
              <div className="w-12 h-12 rounded-full bg-[#FF6B47]/10 flex items-center justify-center flex-shrink-0">
                <Phone className="text-[#FF6B47]" size={20} />
              </div>
              <div>
                <div className="font-bold text-[#2D6A4F]">DM to Order</div>
                <div className="text-[#2D6A4F]/70">@sipandflourish on Instagram</div>
              </div>
            </div>
          </div>
        </div>

        <form onSubmit={submit} className="lg:col-span-3 bg-white rounded-3xl shadow-2xl p-8 md:p-10 border border-[#FF6B47]/10">
          <h3 className="font-serif-display text-3xl font-bold text-[#2D6A4F] mb-6">Place Your Order</h3>

          <div className="grid md:grid-cols-2 gap-4 mb-4">
            <div>
              <label className="block text-sm font-semibold text-[#2D6A4F] mb-2">Full Name *</label>
              <input
                value={form.name}
                onChange={(e) => update('name', e.target.value)}
                className="w-full px-4 py-3 rounded-xl border border-[#2D6A4F]/15 focus:border-[#FF6B47] focus:ring-2 focus:ring-[#FF6B47]/20 outline-none transition"
                placeholder="Jane Doe"
              />
            </div>
            <div>
              <label className="block text-sm font-semibold text-[#2D6A4F] mb-2">Email *</label>
              <input
                type="email"
                value={form.email}
                onChange={(e) => update('email', e.target.value)}
                className="w-full px-4 py-3 rounded-xl border border-[#2D6A4F]/15 focus:border-[#FF6B47] focus:ring-2 focus:ring-[#FF6B47]/20 outline-none transition"
                placeholder="jane@email.com"
              />
            </div>
          </div>

          <div className="grid md:grid-cols-2 gap-4 mb-4">
            <div>
              <label className="block text-sm font-semibold text-[#2D6A4F] mb-2">Phone</label>
              <input
                value={form.phone}
                onChange={(e) => update('phone', e.target.value)}
                className="w-full px-4 py-3 rounded-xl border border-[#2D6A4F]/15 focus:border-[#FF6B47] focus:ring-2 focus:ring-[#FF6B47]/20 outline-none transition"
                placeholder="(555) 123-4567"
              />
            </div>
            <div>
              <label className="block text-sm font-semibold text-[#2D6A4F] mb-2">Quantity</label>
              <input
                type="number"
                min={1}
                value={form.quantity}
                onChange={(e) => update('quantity', parseInt(e.target.value) || 1)}
                className="w-full px-4 py-3 rounded-xl border border-[#2D6A4F]/15 focus:border-[#FF6B47] focus:ring-2 focus:ring-[#FF6B47]/20 outline-none transition"
              />
            </div>
          </div>

          <div className="mb-4">
            <label className="block text-sm font-semibold text-[#2D6A4F] mb-2">Select Juice</label>
            <select
              value={form.juice}
              onChange={(e) => update('juice', e.target.value)}
              className="w-full px-4 py-3 rounded-xl border border-[#2D6A4F]/15 focus:border-[#FF6B47] focus:ring-2 focus:ring-[#FF6B47]/20 outline-none transition bg-white"
            >
              {juices.map((j) => <option key={j}>{j}</option>)}
            </select>
          </div>

          <div className="mb-4">
            <label className="block text-sm font-semibold text-[#2D6A4F] mb-2">Delivery or Pickup</label>
            <div className="grid grid-cols-2 gap-3">
              {['delivery', 'pickup'].map((m) => (
                <button
                  key={m}
                  type="button"
                  onClick={() => update('method', m)}
                  className={`py-3 rounded-xl font-semibold capitalize transition-all ${
                    form.method === m
                      ? 'bg-[#2D6A4F] text-white shadow-lg'
                      : 'bg-[#FFF8F0] text-[#2D6A4F] border border-[#2D6A4F]/15'
                  }`}
                >
                  {m}
                </button>
              ))}
            </div>
          </div>

          <div className="mb-6">
            <label className="block text-sm font-semibold text-[#2D6A4F] mb-2">Special Instructions</label>
            <textarea
              value={form.notes}
              onChange={(e) => update('notes', e.target.value)}
              rows={3}
              className="w-full px-4 py-3 rounded-xl border border-[#2D6A4F]/15 focus:border-[#FF6B47] focus:ring-2 focus:ring-[#FF6B47]/20 outline-none transition resize-none"
              placeholder="Any allergies, delivery notes, or special requests..."
            />
          </div>

          <button
            type="submit"
            disabled={loading}
            className="w-full bg-[#FF6B47] hover:bg-[#e55a37] text-white py-4 rounded-full font-bold text-lg shadow-xl shadow-[#FF6B47]/30 hover:shadow-2xl transition-all hover:-translate-y-1 disabled:opacity-60 flex items-center justify-center gap-2"
          >
            <Send size={20} />
            {loading ? 'Sending...' : 'Place My Order'}
          </button>
        </form>
      </div>
    </section>
  );
};

export default Order;
