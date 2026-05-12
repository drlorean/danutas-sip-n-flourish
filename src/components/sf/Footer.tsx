import React, { useState } from 'react';
import { Instagram, Facebook, Twitter, Heart } from 'lucide-react';
import { toast } from 'sonner';

const Footer: React.FC = () => {
  const [email, setEmail] = useState('');
  const subscribe = async (e: React.FormEvent) => {
    e.preventDefault();
    if (!email) return;
    try {
      await fetch('https://famous.ai/api/crm/6a018525486a1600bdce72d0/subscribe', {
        method: 'POST',
        headers: { 'Content-Type': 'application/json' },
        body: JSON.stringify({
          email,
          source: 'footer-signup',
          tags: ['newsletter', 'footer'],
        }),
      });
      toast.success('Welcome to the flourish family! 🌸');
      setEmail('');
    } catch {
      toast.error('Something went wrong. Try again!');
    }
  };

  const scrollTo = (id: string) =>
    document.getElementById(id)?.scrollIntoView({ behavior: 'smooth' });

  return (
    <footer className="bg-[#1B4332] text-white pt-20 pb-8 px-6 relative overflow-hidden">
      <div className="absolute top-10 left-10 text-9xl opacity-5 select-none">🍊</div>
      <div className="absolute bottom-10 right-10 text-9xl opacity-5 select-none">🌿</div>

      <div className="max-w-7xl mx-auto relative">
        <div className="grid md:grid-cols-2 lg:grid-cols-4 gap-12 mb-12">
          <div className="lg:col-span-1">
            <div className="flex items-center gap-2 mb-4">
              <div className="w-12 h-12 rounded-full bg-gradient-to-br from-[#FF6B47] to-[#F4A226] flex items-center justify-center text-white font-serif-display text-2xl font-bold">
                S
              </div>
              <span className="font-serif-display text-2xl font-bold">Sip & Flourish</span>
            </div>
            <p className="font-serif-display italic text-[#F4A226] mb-4">
              Freshly Pressed. Naturally You.
            </p>
            <p className="text-white/70 text-sm leading-relaxed">
              Artisan cold-pressed juices crafted with love by women, for everyone seeking to flourish.
            </p>
          </div>

          <div>
            <h4 className="font-serif-display text-lg font-bold mb-4 text-[#F4A226]">Explore</h4>
            <ul className="space-y-3 text-white/80">
              {['Home', 'About', 'Menu', 'Why Us', 'Reviews', 'Order'].map((l) => (
                <li key={l}>
                  <button
                    onClick={() => scrollTo(l.toLowerCase().replace(' ', ''))}
                    className="hover:text-[#FF6B47] transition-colors"
                  >
                    {l}
                  </button>
                </li>
              ))}
            </ul>
          </div>

          <div>
            <h4 className="font-serif-display text-lg font-bold mb-4 text-[#F4A226]">Contact</h4>
            <ul className="space-y-3 text-white/80 text-sm">
              <li>📍 Local Pop-Up Markets</li>
              <li>📧 hello@sipandflourish.com</li>
              <li>📱 @sipandflourish</li>
            </ul>
            <div className="flex gap-3 mt-6">
              {[Instagram, Facebook, Twitter].map((Icon, i) => (
                <a
                  key={i}
                  href="#"
                  className="w-10 h-10 rounded-full bg-white/10 hover:bg-[#FF6B47] flex items-center justify-center transition-all hover:-translate-y-1"
                >
                  <Icon size={18} />
                </a>
              ))}
              <a
                href="#"
                className="w-10 h-10 rounded-full bg-white/10 hover:bg-[#FF6B47] flex items-center justify-center transition-all hover:-translate-y-1 font-bold text-xs"
              >
                TT
              </a>
            </div>
          </div>

          <div>
            <h4 className="font-serif-display text-lg font-bold mb-4 text-[#F4A226]">Newsletter</h4>
            <p className="text-white/70 text-sm mb-4">
              Get juice drops, recipes & community love in your inbox.
            </p>
            <form onSubmit={subscribe} className="space-y-3">
              <input
                type="email"
                required
                value={email}
                onChange={(e) => setEmail(e.target.value)}
                placeholder="Your email"
                className="w-full px-4 py-3 rounded-full bg-white/10 border border-white/20 text-white placeholder-white/40 focus:border-[#FF6B47] outline-none text-sm"
              />
              <button
                type="submit"
                className="w-full bg-[#FF6B47] hover:bg-[#e55a37] text-white py-3 rounded-full font-semibold transition-all hover:-translate-y-0.5"
              >
                Subscribe
              </button>
            </form>
          </div>
        </div>

        <div className="border-t border-white/10 pt-8 flex flex-col md:flex-row items-center justify-between gap-4">
          <p className="text-white/60 text-sm text-center md:text-left">
            © 2025 Sip & Flourish. Women-Owned. Freshly Pressed. All Rights Reserved.
          </p>
          <p className="text-white/60 text-sm flex items-center gap-1">
            Made with <Heart size={14} fill="#52B788" className="text-[#52B788]" /> and a whole lot of fruit
          </p>
        </div>
      </div>
    </footer>
  );
};

export default Footer;
