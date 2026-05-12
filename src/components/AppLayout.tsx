import React from 'react';
import Header from './sf/Header';
import Hero from './sf/Hero';
import Marquee from './sf/Marquee';
import About from './sf/About';
import Menu from './sf/Menu';
import Benefits from './sf/Benefits';
import Testimonials from './sf/Testimonials';
import InstagramFeed from './sf/Instagram';
import Order from './sf/Order';
import Footer from './sf/Footer';

const AppLayout: React.FC = () => {
  return (
    <div className="min-h-screen bg-[#FFF8F0] font-sans-body text-[#2D6A4F]">
      <Header />
      <Hero />
      <Marquee />
      <About />
      <Menu />
      <Benefits />
      <Testimonials />
      <InstagramFeed />
      <Order />
      <Footer />
    </div>
  );
};

export default AppLayout;
