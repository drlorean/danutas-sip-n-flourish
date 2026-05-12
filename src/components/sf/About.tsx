import React from 'react';
import { Heart, Leaf } from 'lucide-react';

const About: React.FC = () => {
  return (
    <section id="about" className="py-24 px-6 bg-[#FFF8F0] relative overflow-hidden">
      <div className="absolute top-10 right-10 text-9xl opacity-5 select-none">🍃</div>
      <div className="absolute bottom-10 left-10 text-9xl opacity-5 select-none">🍊</div>

      <div className="max-w-7xl mx-auto grid lg:grid-cols-2 gap-16 items-center">
        <div className="relative">
          <div className="absolute -inset-6 bg-gradient-to-br from-[#F4A226]/20 to-[#FF6B47]/20 rounded-3xl rotate-3" />
          <div className="relative rounded-3xl overflow-hidden shadow-2xl">
            <img
              src="https://d64gsuwffb70l.cloudfront.net/6a018525486a1600bdce72d0_1778485082251_9e3c41c1.png"
              alt="Sip & Flourish founder"
              className="w-full h-[600px] object-cover"
            />
          </div>
          <div className="absolute -bottom-8 -right-4 bg-white rounded-2xl shadow-xl px-6 py-4 flex items-center gap-3">
            <div className="w-12 h-12 rounded-full bg-gradient-to-br from-[#FF6B47] to-[#F4A226] flex items-center justify-center text-white">
              <Heart size={22} fill="white" />
            </div>
            <div>
              <div className="font-serif-display font-bold text-[#2D6A4F] text-lg">Women-Owned</div>
              <div className="text-xs text-[#2D6A4F]/70 uppercase tracking-widest">& Operated</div>
            </div>
          </div>
        </div>

        <div>
          <div className="inline-flex items-center gap-2 text-[#FF6B47] font-semibold uppercase tracking-[0.2em] text-sm mb-4">
            <Leaf size={16} />
            Our Story
          </div>

          <h2 className="font-serif-display text-5xl md:text-6xl font-bold text-[#2D6A4F] leading-tight mb-8">
            Born from <span className="italic text-[#FF6B47]">Passion.</span><br />
            Built with <span className="italic text-[#F4A226]">Purpose.</span>
          </h2>

          <p className="text-lg text-[#2D6A4F]/80 leading-relaxed mb-6">
            Sip & Flourish was born from one woman's desire to bring vibrant,
            nourishing juice to her community. What started as a kitchen experiment
            blossomed into a movement of wellness, empowerment, and pure joy.
          </p>

          <p className="text-lg text-[#2D6A4F]/80 leading-relaxed mb-8">
            Every bottle is pressed fresh daily with locally sourced fruits — no
            preservatives, no shortcuts, just pure goodness in every sip. Because
            when you nourish yourself, you flourish.
          </p>

          <div className="grid grid-cols-2 gap-6 pt-8 border-t border-[#2D6A4F]/10">
            <div>
              <div className="font-serif-display text-4xl font-bold text-[#FF6B47]">5+</div>
              <div className="text-[#2D6A4F]/70 mt-1">Years of love & juice</div>
            </div>
            <div>
              <div className="font-serif-display text-4xl font-bold text-[#FF6B47]">10K+</div>
              <div className="text-[#2D6A4F]/70 mt-1">Bottles pressed</div>
            </div>
          </div>
        </div>
      </div>
    </section>
  );
};

export default About;
