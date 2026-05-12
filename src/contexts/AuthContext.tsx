import React, { createContext, useContext, useState, useEffect, ReactNode } from 'react';
import { supabase } from '@/lib/supabase';

interface Account {
  id: string;
  email: string;
  name?: string;
  phone?: string;
  loyalty_points: number;
  created_at?: string;
}

interface AuthContextType {
  account: Account | null;
  loading: boolean;
  signIn: (email: string, password: string) => Promise<void>;
  signUp: (email: string, password: string, name?: string, phone?: string) => Promise<void>;
  signOut: () => void;
  refresh: () => Promise<void>;
  updateProfile: (name: string, phone: string) => Promise<void>;
}

const AuthContext = createContext<AuthContextType | undefined>(undefined);

const TOKEN_KEY = 'sf_auth_token';

export const AuthProvider: React.FC<{ children: ReactNode }> = ({ children }) => {
  const [account, setAccount] = useState<Account | null>(null);
  const [loading, setLoading] = useState(true);

  const callAuth = async (action: string, body: Record<string, any>) => {
    const { data, error } = await supabase.functions.invoke('customer-auth', {
      body: { action, ...body },
    });
    if (error) throw new Error(error.message);
    if (data?.error) throw new Error(data.error);
    return data;
  };

  const refresh = async () => {
    const token = localStorage.getItem(TOKEN_KEY);
    if (!token) {
      setAccount(null);
      setLoading(false);
      return;
    }
    try {
      const data = await callAuth('me', { token });
      setAccount(data.account);
    } catch {
      localStorage.removeItem(TOKEN_KEY);
      setAccount(null);
    } finally {
      setLoading(false);
    }
  };

  useEffect(() => {
    refresh();
  }, []);

  const signIn = async (email: string, password: string) => {
    const data = await callAuth('login', { email, password });
    localStorage.setItem(TOKEN_KEY, data.token);
    setAccount(data.account);
  };

  const signUp = async (email: string, password: string, name?: string, phone?: string) => {
    const data = await callAuth('signup', { email, password, name, phone });
    localStorage.setItem(TOKEN_KEY, data.token);
    setAccount(data.account);
  };

  const signOut = () => {
    localStorage.removeItem(TOKEN_KEY);
    setAccount(null);
  };

  const updateProfile = async (name: string, phone: string) => {
    const token = localStorage.getItem(TOKEN_KEY);
    if (!token) throw new Error('Not signed in');
    const data = await callAuth('update-profile', { token, name, phone });
    setAccount(data.account);
  };

  return (
    <AuthContext.Provider value={{ account, loading, signIn, signUp, signOut, refresh, updateProfile }}>
      {children}
    </AuthContext.Provider>
  );
};

export const useAuth = () => {
  const ctx = useContext(AuthContext);
  if (!ctx) throw new Error('useAuth must be used within AuthProvider');
  return ctx;
};
