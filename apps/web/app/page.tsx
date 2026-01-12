"use client";

import React, { useState, useRef, useEffect } from "react";
import { Send, Upload, Cpu, Shield, Zap, Paperclip } from "lucide-react";
import { motion, AnimatePresence } from "framer-motion";

export default function Home() {
  const [messages, setMessages] = useState<{ role: string; content: string }[]>([]);
  const [input, setInput] = useState("");
  const [isUploading, setIsUploading] = useState(false);
  const [isTyping, setIsTyping] = useState(false);
  const scrollRef = useRef<HTMLDivElement>(null);

  const API_URL = process.env.NEXT_PUBLIC_API_URL || "http://localhost:8000";

  useEffect(() => {
    if (scrollRef.current) {
      scrollRef.current.scrollTop = scrollRef.current.scrollHeight;
    }
  }, [messages]);

  const handleSend = async () => {
    if (!input.trim()) return;

    const userMessage = { role: "user", content: input };
    setMessages((prev) => [...prev, userMessage]);
    setInput("");
    setIsTyping(true);

    try {
      const res = await fetch(`${API_URL}/chat`, {
        method: "POST",
        headers: { "Content-Type": "application/json" },
        body: JSON.stringify({ message: input }),
      });
      const data = await res.json();
      setMessages((prev) => [...prev, { role: "assistant", content: data.response }]);
    } catch (error) {
      setMessages((prev) => [...prev, { role: "assistant", content: "System Error: Connection to Neural Link lost." }]);
    } finally {
      setIsTyping(false);
    }
  };

  const handleUpload = async (e: React.ChangeEvent<HTMLInputElement>) => {
    const file = e.target.files?.[0];
    if (!file) return;

    setIsUploading(true);
    const formData = new FormData();
    formData.append("file", file);

    try {
      const res = await fetch(`${API_URL}/ingest`, {
        method: "POST",
        body: formData,
      });
      const data = await res.json();
      if (data.status === "success") {
        setMessages((prev) => [...prev, { role: "system", content: `Data Uplink Complete: ${file.filename} indexed.` }]);
      }
    } catch (error) {
      setMessages((prev) => [...prev, { role: "system", content: "Uplink Failed: Transmission corrupted." }]);
    } finally {
      setIsUploading(false);
    }
  };

  return (
    <div className="flex flex-col h-screen bg-[#050505] text-white overflow-hidden">
      {/* Header */}
      <header className="flex items-center justify-between px-8 py-6 border-b border-[#1a1a1a] bg-[#080808]">
        <div className="flex items-center gap-3">
          <div className="p-2 bg-[#00f3ff22] rounded-lg border border-[#00f3ff]">
            <Cpu className="w-6 h-6 text-[#00f3ff]" />
          </div>
          <h1 className="text-xl font-bold tracking-tighter uppercase">
            RAG<span className="text-[#00f3ff]">Agent</span>.SYS
          </h1>
        </div>
        <div className="flex items-center gap-6 text-xs font-mono text-gray-500 uppercase tracking-widest">
          <div className="flex items-center gap-2">
            <Shield className="w-4 h-4 text-green-500" /> Secure
          </div>
          <div className="flex items-center gap-2">
            <Zap className="w-4 h-4 text-yellow-500" /> Active
          </div>
        </div>
      </header>

      {/* Chat Area */}
      <main ref={scrollRef} className="flex-1 overflow-y-auto p-8 space-y-6">
        <AnimatePresence>
          {messages.length === 0 && (
            <motion.div 
              initial={{ opacity: 0, y: 20 }}
              animate={{ opacity: 1, y: 0 }}
              className="h-full flex flex-col items-center justify-center text-center max-w-2xl mx-auto"
            >
              <div className="p-6 rounded-full bg-[#00f3ff11] mb-8">
                <Cpu className="w-16 h-16 text-[#00f3ff] animate-pulse" />
              </div>
              <h2 className="text-4xl font-black mb-4 tracking-tight uppercase">Awaiting Commands</h2>
              <p className="text-gray-400 font-mono text-sm leading-relaxed">
                Initialize neural link by uploading documentation or querying the system. 
                Hybrid Vector-Search protocols active.
              </p>
            </motion.div>
          )}

          {messages.map((msg, i) => (
            <motion.div
              key={i}
              initial={{ opacity: 0, x: msg.role === 'user' ? 20 : -20 }}
              animate={{ opacity: 1, x: 0 }}
              className={`flex ${msg.role === 'user' ? 'justify-end' : 'justify-start'}`}
            >
              <div className={`max-w-[80%] p-4 rounded-xl border ${
                msg.role === 'user' 
                  ? 'bg-[#1a1a1a] border-[#333]' 
                  : msg.role === 'system'
                  ? 'bg-[#bc13fe11] border-[#bc13fe44] text-[#bc13fe]'
                  : 'bg-[#080808] border-[#00f3ff44] neon-border'
              }`}>
                <div className="text-xs font-mono text-gray-500 mb-2 uppercase tracking-widest">
                  {msg.role}
                </div>
                <div className="text-sm leading-relaxed whitespace-pre-wrap">
                  {msg.content}
                </div>
              </div>
            </motion.div>
          ))}

          {isTyping && (
            <div className="flex justify-start">
              <div className="bg-[#080808] border border-[#00f3ff44] p-4 rounded-xl">
                <div className="flex gap-1">
                  <span className="w-1.5 h-1.5 bg-[#00f3ff] rounded-full animate-bounce" />
                  <span className="w-1.5 h-1.5 bg-[#00f3ff] rounded-full animate-bounce [animation-delay:0.2s]" />
                  <span className="w-1.5 h-1.5 bg-[#00f3ff] rounded-full animate-bounce [animation-delay:0.4s]" />
                </div>
              </div>
            </div>
          )}
        </AnimatePresence>
      </main>

      {/* Input Area */}
      <footer className="p-8 bg-[#080808] border-t border-[#1a1a1a]">
        <div className="max-w-4xl mx-auto relative flex items-center gap-4">
          <label className="cursor-pointer group">
            <input type="file" className="hidden" onChange={handleUpload} disabled={isUploading} />
            <div className={`p-4 rounded-xl border transition-all ${
              isUploading ? 'bg-gray-800 border-gray-700' : 'bg-[#1a1a1a] border-[#333] group-hover:border-[#bc13fe]'
            }`}>
              <Paperclip className={`w-5 h-5 ${isUploading ? 'text-gray-500' : 'text-gray-400 group-hover:text-[#bc13fe]'}`} />
            </div>
          </label>

          <div className="flex-1 relative">
            <input
              type="text"
              value={input}
              onChange={(e) => setInput(e.target.value)}
              onKeyDown={(e) => e.key === 'Enter' && handleSend()}
              placeholder="System Query..."
              className="w-full bg-[#1a1a1a] border border-[#333] text-white p-4 rounded-xl focus:outline-none focus:border-[#00f3ff] transition-all placeholder:text-gray-600 font-mono"
            />
          </div>

          <button 
            onClick={handleSend}
            disabled={!input.trim()}
            className="p-4 bg-[#00f3ff] text-black rounded-xl hover:bg-[#00d8e4] transition-all disabled:opacity-50 disabled:cursor-not-allowed"
          >
            <Send className="w-5 h-5" />
          </button>
        </div>
        <div className="mt-4 text-center">
          <span className="text-[10px] font-mono text-gray-600 uppercase tracking-[0.2em]">
            V.2.0.4 - Azure AI Integrated - Production Ready
          </span>
        </div>
      </footer>
    </div>
  );
}