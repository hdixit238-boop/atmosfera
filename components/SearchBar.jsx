"use client";
import { useState, useRef, useEffect } from "react";
import { searchCities } from "@/lib/weather";
import styles from "./SearchBar.module.css";
export default function SearchBar({ onSearch, onLocationClick }) {
  const [query, setQuery] = useState("");
  const [suggestions, setSuggestions] = useState([]);
  const [open, setOpen] = useState(false);
  const [loading, setLoading] = useState(false);
  const debounceRef = useRef(null);
  useEffect(() => {
    if (query.length < 2) { setSuggestions([]); setOpen(false); return; }
    clearTimeout(debounceRef.current);
    debounceRef.current = setTimeout(async () => {
      setLoading(true);
      const res = await searchCities(query);
      setSuggestions(res); setOpen(res.length > 0); setLoading(false);
    }, 350);
    return () => clearTimeout(debounceRef.current);
  }, [query]);
  const handleSelect = (city) => {
    const name = city.local_names?.en || city.name;
    const full = city.state ? `${name}, ${city.state}, ${city.country}` : `${name}, ${city.country}`;
    onSearch(full); setQuery(""); setOpen(false);
  };
  const handleSubmit = (e) => {
    e.preventDefault();
    if (query.trim()) { onSearch(query.trim()); setQuery(""); setOpen(false); }
  };
  return (
    <div className={styles.wrapper}>
      <form onSubmit={handleSubmit} className={styles.form}>
        <div className={styles.inputWrap}>
          <svg className={styles.searchIcon} width="18" height="18" viewBox="0 0 24 24" fill="none" stroke="currentColor" strokeWidth="2"><circle cx="11" cy="11" r="8"/><path d="m21 21-4.35-4.35"/></svg>
          <input className={styles.input} type="text" placeholder="Search city..." value={query} onChange={e => setQuery(e.target.value)} onFocus={() => suggestions.length > 0 && setOpen(true)} />
          {loading && <div className={styles.spinner} />}
          <button type="button" className={styles.locationBtn} onClick={onLocationClick} title="Use my location">
            <svg width="16" height="16" viewBox="0 0 24 24" fill="none" stroke="currentColor" strokeWidth="2"><path d="M21 10c0 7-9 13-9 13s-9-6-9-13a9 9 0 0 1 18 0z"/><circle cx="12" cy="10" r="3"/></svg>
          </button>
        </div>
        {open && (
          <ul className={styles.dropdown}>
            {suggestions.map((c,i) => (
              <li key={i} className={styles.suggestion} onMouseDown={() => handleSelect(c)}>
                <svg width="14" height="14" viewBox="0 0 24 24" fill="none" stroke="currentColor" strokeWidth="2" style={{opacity:0.4}}><path d="M21 10c0 7-9 13-9 13s-9-6-9-13a9 9 0 0 1 18 0z"/><circle cx="12" cy="10" r="3"/></svg>
                <span>{c.local_names?.en || c.name}</span>
                <span className={styles.country}>{c.state ? `${c.state}, ` : ""}{c.country}</span>
              </li>
            ))}
          </ul>
        )}
      </form>
    </div>
  );
}
