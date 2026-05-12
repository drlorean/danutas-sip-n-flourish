import { useEffect, useState } from 'react';
import { getCart, CartItem } from '@/lib/cart';

export const useCart = () => {
  const [cart, setCart] = useState<CartItem[]>([]);

  useEffect(() => {
    setCart(getCart());
    const sync = () => setCart(getCart());
    window.addEventListener('cart-updated', sync);
    window.addEventListener('storage', sync);
    return () => {
      window.removeEventListener('cart-updated', sync);
      window.removeEventListener('storage', sync);
    };
  }, []);

  return cart;
};
