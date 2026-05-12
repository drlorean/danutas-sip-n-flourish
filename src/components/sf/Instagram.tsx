import React from 'react';
import { Instagram as IGIcon, Heart } from 'lucide-react';

const images = [
  'https://d64gsuwffb70l.cloudfront.net/6a018525486a1600bdce72d0_1778485133251_889c7c22.jpg',
  'https://d64gsuwffb70l.cloudfront.net/6a018525486a1600bdce72d0_1778485135772_1d8e5448.jpg',
  'https://d64gsuwffb70l.cloudfront.net/6a018525486a1600bdce72d0_1778485150811_132dbcfc.png',
  'https://d64gsuwffb70l.cloudfront.net/6a018525486a1600bdce72d0_1778485135377_c79d9fdd.jpg',
  'https://d64gsuwffb70l.cloudfront.net/6a018525486a1600bdce72d0_1778485144227_95a087d1.png',
  'https://d64gsuwffb70l.cloudfront.net/6a018525486a1600bdce72d0_1778485142841_19826f65.png',
];

const InstagramFeed: React.FC = () => {
  return (
    <section className="py-24 px-6 bg-[#FFF8F0]">
      <div className="max-w-7xl mx-auto">
        <div className="text-center mb-12">
          <div className="inline-flex items-center gap-2 text-[#FF6B47] font-semibold uppercase tracking-[0.2em] text-sm mb-4">
            <IGIcon size={16} /> Follow The Journey
          </div>
          <h2 className="font-serif-display text-5xl md:text-6xl font-bold text-[#2D6A4F] mb-4">
            <span className="italic">@sipandflourish</span>
          </h2>
          <p className="text-lg text-[#2D6A4F]/70">Join our community of flourishers on Instagram.</p>
        </div>

        <div className="grid grid-cols-2 md:grid-cols-3 lg:grid-cols-6 gap-3 mb-10">
          {images.map((src, i) => (
            <a
              key={i}
              href="https://instagram.com"
              target="_blank"
              rel="noreferrer"
              className="group relative aspect-square overflow-hidden rounded-2xl shadow-md"
            >
              <img
                src={src}
                alt={`Instagram post ${i + 1}`}
                className="w-full h-full object-cover group-hover:scale-110 transition-transform duration-500"
              />
              <div className="absolute inset-0 bg-gradient-to-br from-[#FF6B47] to-[#F4A226] opacity-0 group-hover:opacity-80 transition-opacity flex flex-col items-center justify-center text-white">
                <IGIcon size={32} className="mb-2" />
                <div className="flex items-center gap-1 font-semibold">
                  <Heart size={16} fill="white" /> {120 + i * 23}
                </div>
              </div>
            </a>
          ))}
        </div>

        <div className="text-center">
          <a
            href="https://instagram.com"
            target="_blank"
            rel="noreferrer"
            className="inline-flex items-center gap-2 bg-gradient-to-r from-[#FF6B47] to-[#F4A226] text-white px-8 py-4 rounded-full font-semibold shadow-xl hover:-translate-y-1 transition-all"
          >
            <IGIcon size={20} />
            Follow on Instagram
          </a>
        </div>
      </div>
    </section>
  );
};

export default InstagramFeed;
