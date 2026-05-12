import React, { useState, useEffect } from 'react';
import { Menu, X, User, LogOut, Sparkles } from 'lucide-react';
import { useNavigate, useLocation } from 'react-router-dom';
import { useAuth } from '@/contexts/AuthContext';
import AuthModal from './AuthModal';

const Header: React.FC = () => {
  const [scrolled, setScrolled] = useState(false);
  const [open, setOpen] = useState(false);
  const [authOpen, setAuthOpen] = useState(false);
  const [userMenu, setUserMenu] = useState(false);
  const { account, signOut } = useAuth();
  const navigate = useNavigate();
  const location = useLocation();
  const isHome = location.pathname === '/';

  useEffect(() => {
    const onScroll = () => setScrolled(window.scrollY > 30);
    window.addEventListener('scroll', onScroll);
    return () => window.removeEventListener('scroll', onScroll);
  }, []);

  const links = [
    { label: 'Home', id: 'home' },
    { label: 'About', id: 'about' },
    { label: 'Menu', id: 'menu' },
    { label: 'Why Us', id: 'why' },
    { label: 'Reviews', id: 'reviews' },
    { label: 'Order', id: 'order' },
  ];

  const scrollTo = (id: string) => {
    if (!isHome) {
      navigate('/');
      setTimeout(() => document.getElementById(id)?.scrollIntoView({ behavior: 'smooth' }), 100);
    } else {
      document.getElementById(id)?.scrollIntoView({ behavior: 'smooth' });
    }
    setOpen(false);
  };

  return (
    <>
      <header
        className={`fixed top-0 left-0 right-0 z-50 transition-all duration-300 ${
          scrolled || !isHome ? 'bg-[#FFF8F0]/95 backdrop-blur-md shadow-md py-3' : 'bg-transparent py-5'
        }`}
      >
        <div className="max-w-7xl mx-auto px-6 flex items-center justify-between">
          <button onClick={() => { navigate('/'); window.scrollTo({ top: 0, behavior: 'smooth' }); }} className="flex items-center gap-2 group">
            <div className="w-10 h-10 rounded-full bg-gradient-to-br from-[#FF6B47] to-[#F4A226] flex items-center justify-center text-white font-serif-display text-xl font-bold shadow-lg group-hover:scale-110 transition-transform">
              S
            </div>
            <span className="font-serif-display text-xl md:text-2xl font-bold text-[#2D6A4F]">
              Sip & Flourish
            </span>
          </button>

          <nav className="hidden lg:flex items-center gap-7">
            {links.map((l) => (
              <button
                key={l.id}
                onClick={() => scrollTo(l.id)}
                className="text-[#2D6A4F] font-medium hover:text-[#FF6B47] transition-colors text-sm tracking-wide"
              >
                {l.label}
              </button>
            ))}

            {account ? (
              <div className="relative">
                <button
                  onClick={() => setUserMenu(!userMenu)}
                  className="flex items-center gap-2 bg-[#2D6A4F]/10 hover:bg-[#2D6A4F]/20 text-[#2D6A4F] px-4 py-2 rounded-full font-semibold text-sm transition"
                >
                  <User size={16} />
                  <span className="max-w-[100px] truncate">{account.name || account.email.split('@')[0]}</span>
                </button>
                {userMenu && (
                  <>
                    <div className="fixed inset-0" onClick={() => setUserMenu(false)} />
                    <div className="absolute right-0 mt-2 w-64 bg-white rounded-2xl shadow-xl border border-[#2D6A4F]/10 overflow-hidden z-50">
                      <div className="p-4 bg-gradient-to-br from-[#FF6B47] to-[#F4A226] text-white">
                        <div className="font-semibold truncate">{account.name || account.email}</div>
                        <div className="flex items-center gap-1.5 text-xs mt-1 opacity-90">
                          <Sparkles size={14} />
                          {account.loyalty_points} Loyalty Points
                        </div>
                      </div>
                      <button
                        onClick={() => { setUserMenu(false); navigate('/account'); }}
                        className="w-full text-left px-4 py-3 hover:bg-[#FFF8F0] text-[#2D6A4F] font-medium border-b border-[#2D6A4F]/5"
                      >
                        My Dashboard
                      </button>
                      <button
                        onClick={() => { setUserMenu(false); navigate('/account?tab=orders'); }}
                        className="w-full text-left px-4 py-3 hover:bg-[#FFF8F0] text-[#2D6A4F] font-medium border-b border-[#2D6A4F]/5"
                      >
                        My Orders
                      </button>
                      <button
                        onClick={() => { setUserMenu(false); navigate('/account?tab=addresses'); }}
                        className="w-full text-left px-4 py-3 hover:bg-[#FFF8F0] text-[#2D6A4F] font-medium border-b border-[#2D6A4F]/5"
                      >
                        Saved Addresses
                      </button>
                      <button
                        onClick={() => { setUserMenu(false); signOut(); }}
                        className="w-full text-left px-4 py-3 hover:bg-red-50 text-red-600 font-medium flex items-center gap-2"
                      >
                        <LogOut size={16} /> Sign Out
                      </button>
                    </div>
                  </>
                )}
              </div>
            ) : (
              <button
                onClick={() => setAuthOpen(true)}
                className="text-[#2D6A4F] hover:text-[#FF6B47] font-semibold text-sm flex items-center gap-1.5 transition"
              >
                <User size={16} /> Sign In
              </button>
            )}

            <button
              onClick={() => scrollTo('order')}
              className="bg-[#FF6B47] hover:bg-[#e55a37] text-white px-6 py-2.5 rounded-full font-semibold shadow-lg shadow-[#FF6B47]/30 hover:shadow-xl transition-all hover:-translate-y-0.5"
            >
              Order Now
            </button>
          </nav>

          <button className="lg:hidden text-[#2D6A4F]" onClick={() => setOpen(!open)}>
            {open ? <X size={28} /> : <Menu size={28} />}
          </button>
        </div>

        {open && (
          <div className="lg:hidden bg-[#FFF8F0] border-t border-[#FF6B47]/20 px-6 py-4 space-y-3">
            {links.map((l) => (
              <button
                key={l.id}
                onClick={() => scrollTo(l.id)}
                className="block w-full text-left text-[#2D6A4F] font-medium py-2"
              >
                {l.label}
              </button>
            ))}
            {account ? (
              <>
                <button
                  onClick={() => { setOpen(false); navigate('/account'); }}
                  className="block w-full text-left text-[#2D6A4F] font-medium py-2"
                >
                  My Account ({account.loyalty_points} pts)
                </button>
                <button
                  onClick={() => { setOpen(false); signOut(); }}
                  className="block w-full text-left text-red-600 font-medium py-2"
                >
                  Sign Out
                </button>
              </>
            ) : (
              <button
                onClick={() => { setOpen(false); setAuthOpen(true); }}
                className="block w-full text-left text-[#2D6A4F] font-medium py-2"
              >
                Sign In / Sign Up
              </button>
            )}
            <button
              onClick={() => scrollTo('order')}
              className="w-full bg-[#FF6B47] text-white py-3 rounded-full font-semibold"
            >
              Order Now
            </button>
          </div>
        )}
      </header>

      <AuthModal open={authOpen} onClose={() => setAuthOpen(false)} />
    </>
  );
};

export default Header;
