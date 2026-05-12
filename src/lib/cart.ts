export interface CartItem {
  product_id: string;
  variant_id?: string;
  quantity: number;
  name: string;
  variant_title?: string;
  sku?: string;
  price: number; // cents
  image?: string;
}

const KEY = 'ecom_cart';

export const getCart = (): CartItem[] => {
  try {
    return JSON.parse(localStorage.getItem(KEY) || '[]');
  } catch {
    return [];
  }
};

export const saveCart = (cart: CartItem[]) => {
  localStorage.setItem(KEY, JSON.stringify(cart));
  window.dispatchEvent(new Event('cart-updated'));
};

export const addToCart = (item: CartItem, qty = 1) => {
  const cart = getCart();
  const idx = cart.findIndex(
    (c) => c.product_id === item.product_id && c.variant_id === item.variant_id
  );
  if (idx >= 0) {
    cart[idx].quantity += qty;
  } else {
    cart.push({ ...item, quantity: qty });
  }
  saveCart(cart);
};

export const removeFromCart = (product_id: string, variant_id?: string) => {
  const cart = getCart().filter(
    (c) => !(c.product_id === product_id && c.variant_id === variant_id)
  );
  saveCart(cart);
};

export const updateQty = (product_id: string, variant_id: string | undefined, qty: number) => {
  const cart = getCart();
  const idx = cart.findIndex(
    (c) => c.product_id === product_id && c.variant_id === variant_id
  );
  if (idx >= 0) {
    if (qty <= 0) cart.splice(idx, 1);
    else cart[idx].quantity = qty;
    saveCart(cart);
  }
};

export const clearCart = () => saveCart([]);

export const cartTotal = (cart: CartItem[]) =>
  cart.reduce((sum, i) => sum + i.price * i.quantity, 0);

export const cartCount = (cart: CartItem[]) =>
  cart.reduce((sum, i) => sum + i.quantity, 0);
