import React, { useEffect, useState } from 'react';
import { useNavigate, useSearchParams } from 'react-router-dom';
import { Sparkles, Package, MapPin, User, LogOut, Repeat, Trophy, Plus, Trash2, Star, Clock, CheckCircle, Truck } from 'lucide-react';
import { useAuth } from '@/contexts/AuthContext';
import { supabase } from '@/lib/supabase';
import { addToCart } from '@/lib/cart';
import Header from '@/components/sf/Header';
import Footer from '@/components/sf/Footer';
import AuthModal from '@/components/sf/AuthModal';

const TABS = [
  { id: 'overview', label: 'Overview', icon: Sparkles },
  { id: 'orders', label: 'My Orders', icon: Package },
  { id: 'addresses', label: 'Addresses', icon: MapPin },
  { id: 'rewards', label: 'Rewards', icon: Trophy },
  { id: 'profile', label: 'Profile', icon: User },
];

const Account: React.FC = () => {
  const { account, loading, signOut, updateProfile } = useAuth();
  const navigate = useNavigate();
  const [params, setParams] = useSearchParams();
  const activeTab = params.get('tab') || 'overview';
  const [orders, setOrders] = useState<any[]>([]);
  const [addresses, setAddresses] = useState<any[]>([]);
  const [ordersLoading, setOrdersLoading] = useState(true);

  useEffect(() => {
    if (!loading && !account) {
      // Show auth modal handled below
    }
  }, [loading, account]);

  useEffect(() => {
    if (!account) return;
    const load = async () => {
      setOrdersLoading(true);
      const { data: ordersData } = await supabase
        .from('ecom_orders')
        .select('*, items:ecom_order_items(*)')
        .eq('account_id', account.id)
        .order('created_at', { ascending: false });
      setOrders(ordersData || []);

      const { data: addrData } = await supabase
        .from('customer_addresses')
        .select('*')
        .eq('account_id', account.id)
        .order('is_default', { ascending: false });
      setAddresses(addrData || []);
      setOrdersLoading(false);
    };
    load();
  }, [account]);

  if (loading) {
    return (
      <div className="min-h-screen bg-[#FFF8F0] flex items-center justify-center">
        <div className="text-[#2D6A4F]">Loading...</div>
      </div>
    );
  }

  if (!account) {
    return (
      <div className="min-h-screen bg-[#FFF8F0]">
        <Header />
        <div className="max-w-md mx-auto pt-40 px-6 text-center">
          <div className="bg-white rounded-3xl shadow-xl p-10">
            <Sparkles className="mx-auto text-[#FF6B47] mb-4" size={48} />
            <h2 className="font-serif-display text-3xl font-bold text-[#2D6A4F] mb-2">Sign in required</h2>
            <p className="text-[#2D6A4F]/70 mb-6">Please sign in to view your account.</p>
            <button
              onClick={() => navigate('/')}
              className="bg-[#FF6B47] text-white px-6 py-3 rounded-full font-semibold"
            >
              Go Home & Sign In
            </button>
          </div>
        </div>
        <AuthModal open={true} onClose={() => navigate('/')} onSuccess={() => window.location.reload()} />
      </div>
    );
  }

  const totalSpent = orders.reduce((sum, o) => sum + (o.total || 0), 0);
  const completedOrders = orders.filter(o => ['paid', 'shipped', 'delivered'].includes(o.status)).length;

  return (
    <div className="min-h-screen bg-[#FFF8F0]">
      <Header />
      <div className="pt-28 pb-16 max-w-7xl mx-auto px-6">
        {/* Greeting */}
        <div className="bg-gradient-to-br from-[#FF6B47] to-[#F4A226] rounded-3xl p-8 md:p-10 text-white mb-8 shadow-xl">
          <div className="flex flex-col md:flex-row md:items-center md:justify-between gap-4">
            <div>
              <p className="text-white/90 mb-1">Welcome back,</p>
              <h1 className="font-serif-display text-4xl md:text-5xl font-bold">
                {account.name || account.email.split('@')[0]}
              </h1>
            </div>
            <div className="bg-white/15 backdrop-blur-sm rounded-2xl p-5 flex items-center gap-3">
              <Trophy size={36} className="text-[#FFF8F0]" />
              <div>
                <div className="text-3xl font-bold">{account.loyalty_points}</div>
                <div className="text-xs uppercase tracking-wider opacity-90">Loyalty Points</div>
              </div>
            </div>
          </div>
        </div>

        <div className="grid lg:grid-cols-[260px_1fr] gap-8">
          {/* Sidebar */}
          <aside className="space-y-2">
            {TABS.map((t) => {
              const Icon = t.icon;
              return (
                <button
                  key={t.id}
                  onClick={() => setParams({ tab: t.id })}
                  className={`w-full flex items-center gap-3 px-4 py-3 rounded-xl font-medium transition ${
                    activeTab === t.id
                      ? 'bg-[#2D6A4F] text-white shadow-lg'
                      : 'bg-white text-[#2D6A4F] hover:bg-[#2D6A4F]/5'
                  }`}
                >
                  <Icon size={18} /> {t.label}
                </button>
              );
            })}
            <button
              onClick={() => { signOut(); navigate('/'); }}
              className="w-full flex items-center gap-3 px-4 py-3 rounded-xl font-medium text-red-600 hover:bg-red-50 transition"
            >
              <LogOut size={18} /> Sign Out
            </button>
          </aside>

          {/* Content */}
          <main className="space-y-6">
            {activeTab === 'overview' && (
              <Overview
                account={account}
                orders={orders}
                totalSpent={totalSpent}
                completedOrders={completedOrders}
                setTab={(t) => setParams({ tab: t })}
              />
            )}
            {activeTab === 'orders' && <Orders orders={orders} loading={ordersLoading} />}
            {activeTab === 'addresses' && (
              <Addresses
                accountId={account.id}
                addresses={addresses}
                onChange={setAddresses}
              />
            )}
            {activeTab === 'rewards' && <Rewards points={account.loyalty_points} totalSpent={totalSpent} orders={orders.length} />}
            {activeTab === 'profile' && <Profile account={account} updateProfile={updateProfile} />}
          </main>
        </div>
      </div>
      <Footer />
    </div>
  );
};

const Overview: React.FC<any> = ({ account, orders, totalSpent, completedOrders, setTab }) => {
  const recentOrders = orders.slice(0, 3);
  const navigate = useNavigate();

  const handleReorder = async (order: any) => {
    if (!order.items?.length) return;
    order.items.forEach((item: any) => {
      addToCart({
        product_id: item.product_id,
        variant_id: item.variant_id || undefined,
        name: item.product_name,
        variant_title: item.variant_title || undefined,
        sku: item.sku || undefined,
        price: item.unit_price,
      }, item.quantity);
    });
    navigate('/checkout');
  };

  return (
    <>
      <div className="grid sm:grid-cols-3 gap-4">
        <StatCard label="Total Orders" value={orders.length} icon={Package} />
        <StatCard label="Total Spent" value={`$${(totalSpent / 100).toFixed(2)}`} icon={Sparkles} />
        <StatCard label="Loyalty Points" value={account.loyalty_points} icon={Trophy} />
      </div>

      <div className="bg-white rounded-2xl shadow p-6">
        <div className="flex items-center justify-between mb-5">
          <h3 className="font-serif-display text-2xl font-bold text-[#2D6A4F]">Recent Orders</h3>
          <button onClick={() => setTab('orders')} className="text-[#FF6B47] font-semibold text-sm hover:underline">
            View All →
          </button>
        </div>
        {recentOrders.length === 0 ? (
          <div className="text-center py-10 text-[#2D6A4F]/60">
            <Package className="mx-auto mb-3 opacity-40" size={40} />
            <p>No orders yet. Time to sip & flourish!</p>
            <button onClick={() => navigate('/')} className="mt-4 bg-[#FF6B47] text-white px-5 py-2 rounded-full font-semibold">
              Browse Juices
            </button>
          </div>
        ) : (
          <div className="space-y-3">
            {recentOrders.map((o) => (
              <OrderRow key={o.id} order={o} onReorder={() => handleReorder(o)} />
            ))}
          </div>
        )}
      </div>
    </>
  );
};

const StatCard: React.FC<any> = ({ label, value, icon: Icon }) => (
  <div className="bg-white rounded-2xl shadow p-5 flex items-center gap-4">
    <div className="w-12 h-12 rounded-xl bg-[#FF6B47]/10 text-[#FF6B47] flex items-center justify-center">
      <Icon size={22} />
    </div>
    <div>
      <div className="text-xs uppercase tracking-wide text-[#2D6A4F]/60">{label}</div>
      <div className="font-bold text-2xl text-[#2D6A4F]">{value}</div>
    </div>
  </div>
);

const statusConfig: Record<string, { color: string; icon: any; label: string }> = {
  pending: { color: 'bg-yellow-100 text-yellow-700', icon: Clock, label: 'Pending' },
  paid: { color: 'bg-blue-100 text-blue-700', icon: CheckCircle, label: 'Paid' },
  shipped: { color: 'bg-purple-100 text-purple-700', icon: Truck, label: 'Shipped' },
  delivered: { color: 'bg-green-100 text-green-700', icon: CheckCircle, label: 'Delivered' },
  cancelled: { color: 'bg-red-100 text-red-700', icon: Clock, label: 'Cancelled' },
};

const OrderRow: React.FC<{ order: any; onReorder: () => void }> = ({ order, onReorder }) => {
  const cfg = statusConfig[order.status] || statusConfig.pending;
  const Icon = cfg.icon;
  return (
    <div className="border border-[#2D6A4F]/10 rounded-xl p-4 hover:border-[#FF6B47]/40 transition">
      <div className="flex flex-wrap items-center justify-between gap-3">
        <div>
          <div className="flex items-center gap-2 mb-1">
            <span className="font-semibold text-[#2D6A4F]">Order #{order.id.slice(0, 8).toUpperCase()}</span>
            <span className={`text-xs font-semibold px-2 py-1 rounded-full inline-flex items-center gap-1 ${cfg.color}`}>
              <Icon size={12} /> {cfg.label}
            </span>
          </div>
          <div className="text-sm text-[#2D6A4F]/60">
            {new Date(order.created_at).toLocaleDateString()} • {order.items?.length || 0} items • ${(order.total / 100).toFixed(2)}
          </div>
        </div>
        <button
          onClick={onReorder}
          className="bg-[#2D6A4F] hover:bg-[#1e4d38] text-white px-4 py-2 rounded-full font-semibold text-sm flex items-center gap-1.5"
        >
          <Repeat size={14} /> Reorder
        </button>
      </div>
      {order.items?.length > 0 && (
        <div className="mt-3 pt-3 border-t border-[#2D6A4F]/5 text-sm text-[#2D6A4F]/70">
          {order.items.map((i: any) => i.product_name).join(' • ')}
        </div>
      )}
    </div>
  );
};

const Orders: React.FC<{ orders: any[]; loading: boolean }> = ({ orders, loading }) => {
  const navigate = useNavigate();
  const handleReorder = (order: any) => {
    order.items?.forEach((item: any) => {
      addToCart({
        product_id: item.product_id,
        variant_id: item.variant_id || undefined,
        name: item.product_name,
        variant_title: item.variant_title || undefined,
        sku: item.sku || undefined,
        price: item.unit_price,
      }, item.quantity);
    });
    navigate('/checkout');
  };

  return (
    <div className="bg-white rounded-2xl shadow p-6">
      <h2 className="font-serif-display text-3xl font-bold text-[#2D6A4F] mb-6">My Orders</h2>
      {loading ? (
        <p className="text-[#2D6A4F]/60">Loading orders...</p>
      ) : orders.length === 0 ? (
        <div className="text-center py-12">
          <Package className="mx-auto mb-4 text-[#2D6A4F]/30" size={56} />
          <p className="text-[#2D6A4F]/70 mb-4">You haven't placed any orders yet.</p>
          <button onClick={() => navigate('/')} className="bg-[#FF6B47] text-white px-6 py-3 rounded-full font-semibold">
            Browse Juices
          </button>
        </div>
      ) : (
        <div className="space-y-4">
          {orders.map((o) => (
            <OrderRow key={o.id} order={o} onReorder={() => handleReorder(o)} />
          ))}
        </div>
      )}
    </div>
  );
};

const Addresses: React.FC<{ accountId: string; addresses: any[]; onChange: (a: any[]) => void }> = ({ accountId, addresses, onChange }) => {
  const [showForm, setShowForm] = useState(false);
  const [form, setForm] = useState({ label: '', name: '', address: '', city: '', state: '', zip: '', country: 'US' });

  const save = async () => {
    const { data, error } = await supabase
      .from('customer_addresses')
      .insert({ ...form, account_id: accountId, is_default: addresses.length === 0 })
      .select()
      .single();
    if (!error && data) {
      onChange([...addresses, data]);
      setShowForm(false);
      setForm({ label: '', name: '', address: '', city: '', state: '', zip: '', country: 'US' });
    }
  };

  const remove = async (id: string) => {
    await supabase.from('customer_addresses').delete().eq('id', id);
    onChange(addresses.filter((a) => a.id !== id));
  };

  const makeDefault = async (id: string) => {
    await supabase.from('customer_addresses').update({ is_default: false }).eq('account_id', accountId);
    await supabase.from('customer_addresses').update({ is_default: true }).eq('id', id);
    onChange(addresses.map((a) => ({ ...a, is_default: a.id === id })));
  };

  return (
    <div className="bg-white rounded-2xl shadow p-6">
      <div className="flex items-center justify-between mb-6">
        <h2 className="font-serif-display text-3xl font-bold text-[#2D6A4F]">Saved Addresses</h2>
        <button
          onClick={() => setShowForm(!showForm)}
          className="bg-[#FF6B47] text-white px-4 py-2 rounded-full font-semibold text-sm flex items-center gap-1.5"
        >
          <Plus size={16} /> Add Address
        </button>
      </div>

      {showForm && (
        <div className="bg-[#FFF8F0] rounded-xl p-5 mb-6 space-y-3">
          <input className="w-full p-3 rounded-lg border border-[#2D6A4F]/15" placeholder="Label (Home, Work...)" value={form.label} onChange={(e) => setForm({ ...form, label: e.target.value })} />
          <input className="w-full p-3 rounded-lg border border-[#2D6A4F]/15" placeholder="Full Name" value={form.name} onChange={(e) => setForm({ ...form, name: e.target.value })} />
          <input className="w-full p-3 rounded-lg border border-[#2D6A4F]/15" placeholder="Street Address" value={form.address} onChange={(e) => setForm({ ...form, address: e.target.value })} />
          <div className="grid grid-cols-3 gap-3">
            <input className="p-3 rounded-lg border border-[#2D6A4F]/15" placeholder="City" value={form.city} onChange={(e) => setForm({ ...form, city: e.target.value })} />
            <input className="p-3 rounded-lg border border-[#2D6A4F]/15" placeholder="State" value={form.state} onChange={(e) => setForm({ ...form, state: e.target.value })} />
            <input className="p-3 rounded-lg border border-[#2D6A4F]/15" placeholder="ZIP" value={form.zip} onChange={(e) => setForm({ ...form, zip: e.target.value })} />
          </div>
          <div className="flex gap-3">
            <button onClick={save} className="flex-1 bg-[#2D6A4F] text-white py-3 rounded-full font-semibold">Save Address</button>
            <button onClick={() => setShowForm(false)} className="px-5 py-3 rounded-full border border-[#2D6A4F]/20 font-semibold">Cancel</button>
          </div>
        </div>
      )}

      {addresses.length === 0 && !showForm ? (
        <div className="text-center py-10 text-[#2D6A4F]/60">
          <MapPin className="mx-auto mb-3 opacity-40" size={40} />
          <p>No saved addresses yet.</p>
        </div>
      ) : (
        <div className="grid sm:grid-cols-2 gap-4">
          {addresses.map((a) => (
            <div key={a.id} className={`border rounded-xl p-4 ${a.is_default ? 'border-[#FF6B47] bg-[#FF6B47]/5' : 'border-[#2D6A4F]/10'}`}>
              <div className="flex items-start justify-between mb-2">
                <div className="font-semibold text-[#2D6A4F]">
                  {a.label || 'Address'}
                  {a.is_default && <span className="ml-2 text-xs bg-[#FF6B47] text-white px-2 py-0.5 rounded-full">Default</span>}
                </div>
                <button onClick={() => remove(a.id)} className="text-red-500 hover:text-red-700">
                  <Trash2 size={16} />
                </button>
              </div>
              <div className="text-sm text-[#2D6A4F]/80 space-y-0.5">
                <div>{a.name}</div>
                <div>{a.address}</div>
                <div>{a.city}, {a.state} {a.zip}</div>
              </div>
              {!a.is_default && (
                <button onClick={() => makeDefault(a.id)} className="mt-3 text-xs text-[#FF6B47] font-semibold hover:underline">
                  Set as default
                </button>
              )}
            </div>
          ))}
        </div>
      )}
    </div>
  );
};

const Rewards: React.FC<{ points: number; totalSpent: number; orders: number }> = ({ points, totalSpent, orders }) => {
  const tiers = [
    { name: 'Fresh', min: 0, max: 200, color: 'from-[#F4A226] to-[#FF6B47]', perk: 'Welcome bonus 50 pts' },
    { name: 'Glow', min: 200, max: 500, color: 'from-[#FF6B47] to-[#e55a37]', perk: '10% off every order' },
    { name: 'Radiant', min: 500, max: 1000, color: 'from-[#2D6A4F] to-[#1e4d38]', perk: 'Free delivery + monthly bonus juice' },
    { name: 'Goddess', min: 1000, max: 9999, color: 'from-purple-500 to-pink-500', perk: 'VIP access & exclusive blends' },
  ];
  const currentTier = tiers.find(t => points >= t.min && points < t.max) || tiers[0];
  const nextTier = tiers[tiers.indexOf(currentTier) + 1];
  const progress = nextTier ? ((points - currentTier.min) / (nextTier.min - currentTier.min)) * 100 : 100;

  return (
    <div className="space-y-6">
      <div className={`bg-gradient-to-br ${currentTier.color} rounded-3xl p-8 text-white shadow-xl`}>
        <div className="flex items-center justify-between">
          <div>
            <div className="text-sm opacity-90 uppercase tracking-wider">Your Tier</div>
            <div className="font-serif-display text-5xl font-bold">{currentTier.name}</div>
            <div className="mt-2 opacity-95">{currentTier.perk}</div>
          </div>
          <Trophy size={64} className="opacity-80" />
        </div>
        {nextTier && (
          <div className="mt-6">
            <div className="flex justify-between text-sm mb-2">
              <span>{points} pts</span>
              <span>{nextTier.min} pts → {nextTier.name}</span>
            </div>
            <div className="h-3 bg-white/20 rounded-full overflow-hidden">
              <div className="h-full bg-white" style={{ width: `${Math.min(100, progress)}%` }} />
            </div>
          </div>
        )}
      </div>

      <div className="bg-white rounded-2xl shadow p-6">
        <h3 className="font-serif-display text-2xl font-bold text-[#2D6A4F] mb-4">How to Earn</h3>
        <div className="grid sm:grid-cols-3 gap-4">
          <RewardCard icon={Package} title="Order Juice" desc="Earn 10 pts per $1 spent" />
          <RewardCard icon={Star} title="Leave a Review" desc="Earn 50 pts per review" />
          <RewardCard icon={Sparkles} title="Refer a Friend" desc="Earn 100 pts each" />
        </div>
      </div>

      <div className="bg-white rounded-2xl shadow p-6">
        <h3 className="font-serif-display text-2xl font-bold text-[#2D6A4F] mb-4">Rewards You Can Redeem</h3>
        <div className="space-y-3">
          <RedeemRow cost={100} reward="Free juice add-on" available={points >= 100} />
          <RedeemRow cost={250} reward="$5 off your next order" available={points >= 250} />
          <RedeemRow cost={500} reward="Free 6-pack delivery" available={points >= 500} />
          <RedeemRow cost={1000} reward="Custom-blend consultation" available={points >= 1000} />
        </div>
      </div>
    </div>
  );
};

const RewardCard: React.FC<any> = ({ icon: Icon, title, desc }) => (
  <div className="bg-[#FFF8F0] rounded-xl p-5 text-center">
    <Icon className="mx-auto text-[#FF6B47] mb-2" size={28} />
    <div className="font-semibold text-[#2D6A4F]">{title}</div>
    <div className="text-sm text-[#2D6A4F]/70">{desc}</div>
  </div>
);

const RedeemRow: React.FC<{ cost: number; reward: string; available: boolean }> = ({ cost, reward, available }) => (
  <div className={`flex items-center justify-between p-4 rounded-xl border ${available ? 'border-[#FF6B47]/40 bg-[#FF6B47]/5' : 'border-[#2D6A4F]/10 opacity-60'}`}>
    <div>
      <div className="font-semibold text-[#2D6A4F]">{reward}</div>
      <div className="text-sm text-[#2D6A4F]/60">{cost} loyalty points</div>
    </div>
    <button disabled={!available} className="bg-[#FF6B47] text-white px-4 py-2 rounded-full font-semibold text-sm disabled:bg-gray-300 disabled:cursor-not-allowed">
      {available ? 'Redeem' : 'Locked'}
    </button>
  </div>
);

const Profile: React.FC<{ account: any; updateProfile: (n: string, p: string) => Promise<void> }> = ({ account, updateProfile }) => {
  const [name, setName] = useState(account.name || '');
  const [phone, setPhone] = useState(account.phone || '');
  const [saving, setSaving] = useState(false);
  const [saved, setSaved] = useState(false);

  const save = async () => {
    setSaving(true);
    setSaved(false);
    try {
      await updateProfile(name, phone);
      setSaved(true);
      setTimeout(() => setSaved(false), 2000);
    } finally {
      setSaving(false);
    }
  };

  return (
    <div className="bg-white rounded-2xl shadow p-6">
      <h2 className="font-serif-display text-3xl font-bold text-[#2D6A4F] mb-6">Profile</h2>
      <div className="space-y-4 max-w-md">
        <div>
          <label className="block text-sm font-semibold text-[#2D6A4F] mb-1">Email</label>
          <input value={account.email} disabled className="w-full p-3 rounded-lg border border-[#2D6A4F]/15 bg-gray-50 text-[#2D6A4F]/60" />
        </div>
        <div>
          <label className="block text-sm font-semibold text-[#2D6A4F] mb-1">Full Name</label>
          <input value={name} onChange={(e) => setName(e.target.value)} className="w-full p-3 rounded-lg border border-[#2D6A4F]/15 focus:border-[#FF6B47] outline-none" />
        </div>
        <div>
          <label className="block text-sm font-semibold text-[#2D6A4F] mb-1">Phone</label>
          <input value={phone} onChange={(e) => setPhone(e.target.value)} className="w-full p-3 rounded-lg border border-[#2D6A4F]/15 focus:border-[#FF6B47] outline-none" />
        </div>
        <button onClick={save} disabled={saving} className="bg-[#FF6B47] text-white px-6 py-3 rounded-full font-semibold disabled:opacity-60">
          {saving ? 'Saving...' : saved ? '✓ Saved' : 'Save Changes'}
        </button>
      </div>
    </div>
  );
};

export default Account;
