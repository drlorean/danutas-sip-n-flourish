import React, { useEffect, useState } from 'react';
import { Plus, ShoppingBag } from 'lucide-react';
import { useNavigate } from 'react-router-dom';
import { toast } from 'sonner';
import { supabase } from '@/lib/supabase';
import { addToCart } from '@/lib/cart';
import { useCart } from '@/hooks/useCart';

const Menu: React.FC = () => {
  const [products, setProducts] = useState<any[]>([]);
  const cart = useCart();
  const navigate = useNavigate();
  const cartCount = cart.reduce((s, i) => s + i.quantity, 0);

  useEffect(() => {
    supabase.from('ecom_products').select('*').eq('status', 'active').then(({ data }) => {
      // Order by SKU for consistent order
      const sorted = (data || []).sort((a: any, b: any) => (a.sku || '').localeCompare(b.sku || ''));
      setProducts(sorted);
    });
  }, []);

  const handleAdd = (p: any) => {
    addToCart({
      product_id: p.id,
      name: p.name,
      sku: p.sku || p.handle,
      price: p.price,
      image: p.images?.[0],
    }, 1);
    toast.success(`${p.name} added to cart!`, {
      action: { label: 'Checkout', onClick: () => navigate('/checkout') },
    });
  };

  const colorFor = (i: number) => [
    'from-[#FF6B47] to-[#F4A226]',
    'from-[#2D6A4F] to-[#52B788]',
    'from-[#C9184A] to-[#FF6B47]',
    'from-[#F4A226] to-[#FFD60A]',
    'from-[#F4A226] to-[#FF6B47]',
    'from-[#FF6B47] to-[#C9184A]',
  ][i % 6];

  return (
    <section id="menu" className="py-24 px-6 bg-gradient-to-b from-[#FFF8F0] to-[#FFE8D6] relative">
      {cartCount > 0 && (
        <button
          onClick={() => navigate('/checkout')}
          className="fixed bottom-6 right-6 z-40 bg-[#FF6B47] hover:bg-[#e55a37] text-white rounded-full shadow-2xl px-6 py-4 flex items-center gap-3 font-bold hover:-translate-y-1 transition-all"
        >
          <ShoppingBag size={22} />
          <span>Checkout</span>
          <span className="bg-white text-[#FF6B47] rounded-full w-7 h-7 flex items-center justify-center text-sm">{cartCount}</span>
        </button>
      )}

      <div className="max-w-7xl mx-auto">
        <div className="text-center mb-16">
          <div className="inline-flex items-center gap-2 text-[#FF6B47] font-semibold uppercase tracking-[0.2em] text-sm mb-4">
            ✦ The Menu ✦
          </div>
          <h2 className="font-serif-display text-5xl md:text-6xl font-bold text-[#2D6A4F] mb-4">
            Our Signature <span className="italic text-[#FF6B47]">Blends</span>
          </h2>
          <p className="text-lg text-[#2D6A4F]/70 max-w-2xl mx-auto">
            Six bold, beautiful blends crafted to nourish your body and lift your spirit. Free shipping on all orders.
          </p>
        </div>

        <div className="grid md:grid-cols-2 lg:grid-cols-3 gap-8">
          {products.map((p, i) => (
            <div
              key={p.id}
              className="group bg-white rounded-3xl overflow-hidden shadow-lg hover:shadow-2xl transition-all duration-500 hover:-translate-y-2"
            >
              <div className={`relative h-56 bg-gradient-to-br ${colorFor(i)} overflow-hidden`}>
                {p.images?.[0] && (
                  <img
                    src={p.images[0]}
                    alt={p.name}
                    className="absolute inset-0 w-full h-full object-cover mix-blend-overlay opacity-80 group-hover:scale-110 transition-transform duration-700"
                  />
                )}
                <div className="absolute top-4 right-4 w-14 h-14 rounded-full bg-white/95 backdrop-blur flex items-center justify-center text-3xl shadow-lg">
                  {p.metadata?.emoji || '🥤'}
                </div>
                <div className="absolute bottom-4 left-4 bg-white text-[#2D6A4F] px-4 py-1.5 rounded-full font-bold text-sm shadow-lg">
                  ${(p.price / 100).toFixed(2)}
                </div>
              </div>

              <div className="p-6">
                <h3 className="font-serif-display text-2xl font-bold text-[#2D6A4F] mb-2">
                  {p.name}
                </h3>
                <p className="text-[#2D6A4F]/70 text-sm leading-relaxed mb-6 min-h-[40px]">
                  {p.metadata?.ingredients || p.description}
                </p>
                <button
                  onClick={() => handleAdd(p)}
                  className="w-full bg-[#2D6A4F] hover:bg-[#FF6B47] text-white py-3 rounded-full font-semibold flex items-center justify-center gap-2 transition-all group/btn"
                >
                  <Plus size={18} className="group-hover/btn:rotate-90 transition-transform" />
                  Add to Cart
                </button>
              </div>
            </div>
          ))}
        </div>
      </div>
    </section>
  );
};

export default Menu;
