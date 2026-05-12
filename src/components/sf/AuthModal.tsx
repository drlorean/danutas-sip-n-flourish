import React, { useState } from 'react';
import { X, Mail, Lock, User, Phone, Sparkles } from 'lucide-react';
import { useAuth } from '@/contexts/AuthContext';

interface AuthModalProps {
  open: boolean;
  onClose: () => void;
  onSuccess?: () => void;
}

const AuthModal: React.FC<AuthModalProps> = ({ open, onClose, onSuccess }) => {
  const { signIn, signUp } = useAuth();
  const [mode, setMode] = useState<'signin' | 'signup'>('signin');
  const [email, setEmail] = useState('');
  const [password, setPassword] = useState('');
  const [name, setName] = useState('');
  const [phone, setPhone] = useState('');
  const [error, setError] = useState('');
  const [loading, setLoading] = useState(false);

  if (!open) return null;

  const handleSubmit = async (e: React.FormEvent) => {
    e.preventDefault();
    setError('');
    setLoading(true);
    try {
      if (mode === 'signin') {
        await signIn(email, password);
      } else {
        await signUp(email, password, name, phone);
      }
      onSuccess?.();
      onClose();
      setEmail(''); setPassword(''); setName(''); setPhone('');
    } catch (err: any) {
      setError(err.message || 'Something went wrong');
    } finally {
      setLoading(false);
    }
  };

  return (
    <div className="fixed inset-0 z-[100] flex items-center justify-center p-4 bg-black/50 backdrop-blur-sm" onClick={onClose}>
      <div
        className="relative bg-[#FFF8F0] rounded-3xl shadow-2xl max-w-md w-full overflow-hidden"
        onClick={(e) => e.stopPropagation()}
      >
        <div className="bg-gradient-to-br from-[#FF6B47] to-[#F4A226] p-8 text-white relative">
          <button onClick={onClose} className="absolute top-4 right-4 text-white/80 hover:text-white">
            <X size={24} />
          </button>
          <Sparkles className="mb-3" size={32} />
          <h2 className="font-serif-display text-3xl font-bold">
            {mode === 'signin' ? 'Welcome Back' : 'Join the Flourish'}
          </h2>
          <p className="text-white/90 mt-1">
            {mode === 'signin' ? 'Sign in to your account' : 'Create your account & earn 50 loyalty points'}
          </p>
        </div>

        <form onSubmit={handleSubmit} className="p-8 space-y-4">
          {mode === 'signup' && (
            <>
              <div className="relative">
                <User className="absolute left-4 top-1/2 -translate-y-1/2 text-[#2D6A4F]/50" size={18} />
                <input
                  type="text"
                  placeholder="Full Name"
                  value={name}
                  onChange={(e) => setName(e.target.value)}
                  className="w-full pl-12 pr-4 py-3 rounded-xl border-2 border-[#2D6A4F]/15 focus:border-[#FF6B47] focus:outline-none transition bg-white"
                />
              </div>
              <div className="relative">
                <Phone className="absolute left-4 top-1/2 -translate-y-1/2 text-[#2D6A4F]/50" size={18} />
                <input
                  type="tel"
                  placeholder="Phone (optional)"
                  value={phone}
                  onChange={(e) => setPhone(e.target.value)}
                  className="w-full pl-12 pr-4 py-3 rounded-xl border-2 border-[#2D6A4F]/15 focus:border-[#FF6B47] focus:outline-none transition bg-white"
                />
              </div>
            </>
          )}
          <div className="relative">
            <Mail className="absolute left-4 top-1/2 -translate-y-1/2 text-[#2D6A4F]/50" size={18} />
            <input
              type="email"
              placeholder="Email Address"
              value={email}
              onChange={(e) => setEmail(e.target.value)}
              required
              className="w-full pl-12 pr-4 py-3 rounded-xl border-2 border-[#2D6A4F]/15 focus:border-[#FF6B47] focus:outline-none transition bg-white"
            />
          </div>
          <div className="relative">
            <Lock className="absolute left-4 top-1/2 -translate-y-1/2 text-[#2D6A4F]/50" size={18} />
            <input
              type="password"
              placeholder="Password"
              value={password}
              onChange={(e) => setPassword(e.target.value)}
              required
              minLength={6}
              className="w-full pl-12 pr-4 py-3 rounded-xl border-2 border-[#2D6A4F]/15 focus:border-[#FF6B47] focus:outline-none transition bg-white"
            />
          </div>

          {error && (
            <div className="text-sm text-red-600 bg-red-50 p-3 rounded-lg border border-red-200">
              {error}
            </div>
          )}

          <button
            type="submit"
            disabled={loading}
            className="w-full bg-[#FF6B47] hover:bg-[#e55a37] text-white py-3.5 rounded-xl font-semibold shadow-lg shadow-[#FF6B47]/30 transition disabled:opacity-50"
          >
            {loading ? 'Please wait...' : mode === 'signin' ? 'Sign In' : 'Create Account'}
          </button>

          <div className="text-center text-sm text-[#2D6A4F]/70">
            {mode === 'signin' ? "Don't have an account? " : 'Already have an account? '}
            <button
              type="button"
              onClick={() => { setMode(mode === 'signin' ? 'signup' : 'signin'); setError(''); }}
              className="text-[#FF6B47] font-semibold hover:underline"
            >
              {mode === 'signin' ? 'Sign Up' : 'Sign In'}
            </button>
          </div>
        </form>
      </div>
    </div>
  );
};

export default AuthModal;
