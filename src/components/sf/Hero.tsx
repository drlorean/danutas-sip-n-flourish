import React from 'react';
import { ArrowRight } from 'lucide-react';

const Hero: React.FC = () => {
  const scrollTo = (id: string) =>
    document.getElementById(id)?.scrollIntoView({ behavior: 'smooth' });

  return (
    <section
      id="home"
      className="relative min-h-screen flex items-center overflow-hidden pt-24 pb-16"
      style={{
        background:
          'radial-gradient(ellipse at top right, #FFD4B8 0%, #FFF8F0 45%, #FFF8F0 100%)',
      }}
    >
      {/* Floating fruit decorations */}
      <div className="absolute top-32 left-10 text-7xl animate-float-slow opacity-80 select-none">🍊</div>
      <div className="absolute top-40 right-20 text-6xl animate-float-medium opacity-80 select-none">🥭</div>
      <div className="absolute bottom-40 left-20 text-7xl animate-float-medium opacity-70 select-none">🍉</div>
      <div className="absolute bottom-32 right-32 text-6xl animate-float-slow opacity-80 select-none">🥝</div>
      <div className="absolute top-1/2 left-1/3 text-5xl animate-float-slow opacity-60 select-none hidden md:block">🍋</div>
      <div className="absolute top-1/4 right-1/4 text-5xl animate-float-medium opacity-60 select-none hidden md:block">🍓</div>

      {/* Decorative gradient blob */}
      <div className="absolute -top-32 -right-32 w-[500px] h-[500px] rounded-full bg-gradient-to-br from-[#FF6B47]/40 to-[#F4A226]/30 blur-3xl" />
      <div className="absolute -bottom-32 -left-32 w-[400px] h-[400px] rounded-full bg-gradient-to-tr from-[#2D6A4F]/20 to-[#F4A226]/20 blur-3xl" />

      <div className="relative max-w-7xl mx-auto px-6 grid lg:grid-cols-2 gap-12 items-center w-full">
        <div className="animate-fade-in-up">
          <div className="inline-flex items-center gap-2 bg-[#2D6A4F]/10 text-[#2D6A4F] px-4 py-2 rounded-full text-sm font-semibold mb-6">
            <span className="w-2 h-2 rounded-full bg-[#2D6A4F] animate-pulse" />
            Women-Owned • Freshly Pressed Daily
          </div>

          <h1 className="font-serif-display text-6xl md:text-7xl lg:text-8xl font-bold text-[#2D6A4F] leading-[0.95] mb-6">
            <span className="block text-4xl md:text-5xl lg:text-6xl text-[#FF6B47] italic font-normal mb-2">'Danuta's'</span>
            Sip &<br />
            <span className="italic bg-gradient-to-r from-[#FF6B47] via-[#F4A226] to-[#FF6B47] bg-clip-text text-transparent">
              Flourish
            </span>
          </h1>


          <p className="font-serif-display italic text-2xl md:text-3xl text-[#2D6A4F]/80 mb-8">
            Freshly Pressed. Naturally You.
          </p>

          <p className="text-lg text-[#2D6A4F]/70 mb-10 max-w-lg leading-relaxed">
            Artisan cold-pressed juices crafted with locally sourced fruits.
            No additives, no shortcuts — just pure, vibrant goodness in every sip.
          </p>

          <div className="flex flex-wrap gap-4">
            <button
              onClick={() => scrollTo('menu')}
              className="group bg-[#FF6B47] hover:bg-[#e55a37] text-white px-8 py-4 rounded-full font-semibold shadow-xl shadow-[#FF6B47]/40 hover:shadow-2xl hover:shadow-[#FF6B47]/50 transition-all hover:-translate-y-1 inline-flex items-center gap-2"
            >
              Shop Our Juices
              <ArrowRight size={20} className="group-hover:translate-x-1 transition-transform" />
            </button>
            <button
              onClick={() => scrollTo('about')}
              className="border-2 border-[#2D6A4F] text-[#2D6A4F] hover:bg-[#2D6A4F] hover:text-white px-8 py-4 rounded-full font-semibold transition-all hover:-translate-y-1"
            >
              Our Story
            </button>
          </div>

          <div className="mt-12 flex items-center gap-8">
            <div>
              <div className="font-serif-display text-3xl font-bold text-[#2D6A4F]">100%</div>
              <div className="text-sm text-[#2D6A4F]/70">Natural</div>
            </div>
            <div className="w-px h-12 bg-[#2D6A4F]/20" />
            <div>
              <div className="font-serif-display text-3xl font-bold text-[#2D6A4F]">6+</div>
              <div className="text-sm text-[#2D6A4F]/70">Signature Blends</div>
            </div>
            <div className="w-px h-12 bg-[#2D6A4F]/20" />
            <div>
              <div className="font-serif-display text-3xl font-bold text-[#2D6A4F]">Daily</div>
              <div className="text-sm text-[#2D6A4F]/70">Cold Pressed</div>
            </div>
          </div>
        </div>

        <div className="relative animate-fade-in-up" style={{ animationDelay: '0.2s' }}>
          <div className="absolute -inset-4 bg-gradient-to-br from-[#FF6B47]/30 to-[#F4A226]/30 rounded-3xl blur-2xl" />
          <div className="relative rounded-3xl overflow-hidden shadow-2xl border-8 border-white">
            <img
              src="https://d64gsuwffb70l.cloudfront.net/6a018525486a1600bdce72d0_1778485054752_2c0e9abb.png"
              alt="Fresh pressed juices with tropical fruits"
              className="w-full h-[600px] object-cover"
            />
            <div className="absolute inset-0 bg-gradient-to-tr from-[#FF6B47]/20 via-transparent to-transparent" />
          </div>

          {/* Floating badge */}
          <div className="absolute -bottom-6 -left-6 bg-white rounded-2xl shadow-2xl p-4 flex items-center gap-3 max-w-xs">
            <div className="w-12 h-12 rounded-full bg-[#F4A226]/20 flex items-center justify-center text-2xl">
              ⭐
            </div>
            <div>
              <div className="font-bold text-[#2D6A4F]">Customer Favorite</div>
              <div className="text-sm text-[#2D6A4F]/70">5.0 from 200+ reviews</div>
            </div>
          </div>

          <div className="absolute -top-6 -right-6 bg-[#2D6A4F] text-white rounded-2xl shadow-2xl p-4 max-w-[180px]">
            <div className="text-3xl mb-1">🌱</div>
            <div className="font-serif-display font-bold">Locally Sourced</div>
            <div className="text-xs opacity-80">Supporting local farms</div>
          </div>
        </div>
      </div>
    </section>
  );
};

export default Hero;
