import React from 'react';
import { Star, Quote } from 'lucide-react';

const reviews = [
  {
    text: 'Sunrise Glow changed my morning routine forever! I feel energized and glowing every single day.',
    name: 'Monique T.',
    role: 'Wellness Coach',
    initial: 'M',
  },
  {
    text: 'Finally a juice brand that feels like it was made FOR me. Every sip is pure happiness.',
    name: 'Destiny R.',
    role: 'Yoga Instructor',
    initial: 'D',
  },
  {
    text: 'Sip & Flourish is the best thing to happen to my health. Obsessed with Green Goddess!',
    name: 'Aaliyah M.',
    role: 'Entrepreneur',
    initial: 'A',
  },
];

const Testimonials: React.FC = () => {
  return (
    <section
      id="reviews"
      className="py-24 px-6 bg-gradient-to-br from-[#2D6A4F] to-[#1B4332] relative overflow-hidden"
    >
      <div className="absolute top-10 right-10 text-9xl opacity-10 select-none">"</div>
      <div className="absolute bottom-20 left-20 text-9xl opacity-10 select-none rotate-180">"</div>

      <div className="max-w-7xl mx-auto relative">
        <div className="text-center mb-16">
          <div className="inline-flex items-center gap-2 text-[#F4A226] font-semibold uppercase tracking-[0.2em] text-sm mb-4">
            ★ Testimonials ★
          </div>
          <h2 className="font-serif-display text-5xl md:text-6xl font-bold text-white mb-4">
            What Our Community <span className="italic text-[#F4A226]">Is Saying</span>
          </h2>
          <p className="text-white/70 text-lg">Real words from real flourishers.</p>
        </div>

        <div className="grid md:grid-cols-3 gap-8">
          {reviews.map((r) => (
            <div
              key={r.name}
              className="bg-[#FFF8F0] rounded-3xl p-8 shadow-2xl hover:-translate-y-2 transition-transform relative"
            >
              <Quote className="absolute top-6 right-6 text-[#FF6B47]/20" size={48} />

              <div className="flex gap-1 mb-6">
                {[...Array(5)].map((_, i) => (
                  <Star key={i} size={20} fill="#F4A226" className="text-[#F4A226]" />
                ))}
              </div>

              <p className="font-serif-display italic text-xl text-[#2D6A4F] leading-relaxed mb-8">
                "{r.text}"
              </p>

              <div className="flex items-center gap-4 pt-6 border-t border-[#2D6A4F]/10">
                <div className="w-14 h-14 rounded-full bg-gradient-to-br from-[#FF6B47] to-[#F4A226] flex items-center justify-center text-white font-serif-display text-2xl font-bold shadow-lg">
                  {r.initial}
                </div>
                <div>
                  <div className="font-bold text-[#2D6A4F] text-lg">{r.name}</div>
                  <div className="text-sm text-[#2D6A4F]/60">{r.role}</div>
                </div>
              </div>
            </div>
          ))}
        </div>
      </div>
    </section>
  );
};

export default Testimonials;
