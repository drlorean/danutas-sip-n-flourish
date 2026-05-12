import React from 'react';

const items = [
  '🍊 Freshly Pressed Daily',
  '🌿 No Additives',
  '💛 Women-Owned',
  '🥭 Seasonal Flavors',
  '🍋 Cold Pressed',
  '✨ Made with Love',
  '🍓 Locally Sourced',
  '🥥 Pure Goodness',
];

const Marquee: React.FC = () => {
  const loop = [...items, ...items, ...items];
  return (
    <div className="bg-[#2D6A4F] py-5 overflow-hidden border-y-4 border-[#F4A226]">
      <div className="flex animate-marquee whitespace-nowrap">
        {loop.map((t, i) => (
          <div
            key={i}
            className="inline-flex items-center mx-8 text-white font-serif-display italic text-xl md:text-2xl"
          >
            {t}
            <span className="ml-8 text-[#F4A226]">•</span>
          </div>
        ))}
      </div>
    </div>
  );
};

export default Marquee;
