import React from 'react';
import { motion } from 'framer-motion';
export function AnimatedBackground() {
  return <div className="fixed inset-0 z-0 overflow-hidden bg-slate-950">
      <div className="absolute inset-0 bg-[url('https://grainy-gradients.vercel.app/noise.svg')] opacity-20"></div>

      {/* Gradient Orbs */}
      <motion.div animate={{
      scale: [1, 1.2, 1],
      opacity: [0.3, 0.5, 0.3],
      x: [0, 100, 0],
      y: [0, -50, 0]
    }} transition={{
      duration: 20,
      repeat: Infinity,
      ease: 'easeInOut'
    }} className="absolute top-0 left-0 w-[500px] h-[500px] bg-violet-900/40 rounded-full blur-[100px]" />

      <motion.div animate={{
      scale: [1.2, 1, 1.2],
      opacity: [0.3, 0.5, 0.3],
      x: [0, -100, 0],
      y: [0, 50, 0]
    }} transition={{
      duration: 15,
      repeat: Infinity,
      ease: 'easeInOut'
    }} className="absolute bottom-0 right-0 w-[600px] h-[600px] bg-blue-900/30 rounded-full blur-[120px]" />

      <div className="absolute top-1/2 left-1/2 -translate-x-1/2 -translate-y-1/2 w-[800px] h-[800px] bg-indigo-950/20 rounded-full blur-[100px]" />
    </div>;
}