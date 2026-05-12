import React from 'react';
import { Sprout, Zap, Truck, Heart } from 'lucide-react';

const benefits = [
  {
    icon: Sprout,
    title: '100% Natural',
    desc: 'No preservatives, no artificial flavors. Just pure fruit, pure goodness.',
    color: 'bg-[#2D6A4F]',
  },
  {
    icon: Zap,
    title: 'Cold Pressed',
    desc: 'Slow-pressed at low temperatures to retain maximum nutrients and enzymes.',
    color: 'bg-[#FF6B47]',
  },
  {
    icon: Truck,
    title: 'Same-Day Delivery',
    desc: 'Pressed in the morning, delivered to your door before sunset.',
    color: 'bg-[#F4A226]',
  },
  {
    icon: Heart,
    title: 'Locally Sourced',
    desc: 'Supporting local farmers and women-led businesses in our community.',
    color: 'bg-[#2D6A4F]',
  },
];

const Benefits: React.FC = () => {
  return (
    <section id="why" className="py-24 px-6 bg-[#FFF8F0]">
      <div className="max-w-7xl mx-auto">
        <div className="text-center mb-16">
          <div className="inline-flex items-center gap-2 text-[#FF6B47] font-semibold uppercase tracking-[0.2em] text-sm mb-4">
            Why Choose Us
          </div>
          <h2 className="font-serif-display text-5xl md:text-6xl font-bold text-[#2D6A4F] mb-4">
            The Sip & Flourish <span className="italic text-[#FF6B47]">Difference</span>
          </h2>
        </div>

        <div className="grid md:grid-cols-2 lg:grid-cols-4 gap-6">
          {benefits.map((b, i) => {
            const Icon = b.icon;
            return (
              <div
                key={b.title}
                className="group bg-white rounded-3xl p-8 shadow-md hover:shadow-2xl transition-all hover:-translate-y-2 border border-[#FF6B47]/5"
                style={{ animationDelay: `${i * 0.1}s` }}
              >
                <div
                  className={`w-16 h-16 rounded-2xl ${b.color} flex items-center justify-center mb-6 shadow-lg group-hover:scale-110 group-hover:rotate-6 transition-transform`}
                >
                  <Icon size={28} className="text-white" />
                </div>
                <h3 className="font-serif-display text-2xl font-bold text-[#2D6A4F] mb-3">
                  {b.title}
                </h3>
                <p className="text-[#2D6A4F]/70 leading-relaxed">{b.desc}</p>
              </div>
            );
          })}
        </div>
      </div>
    </section>
  );
};

export default Benefits;
