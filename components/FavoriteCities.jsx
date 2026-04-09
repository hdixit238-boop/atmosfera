"use client";
import { useState, useEffect } from "react";
import { fetchWeather } from "@/lib/weather";
import WeatherIcon from "./WeatherIcon";
import styles from "./FavoriteCities.module.css";

const CITIES = ["New York", "London", "Tokyo", "Dubai"];

export default function FavoriteCities({ onSelect, currentCity }) {
  const [cities, setCities] = useState([]);
  const [loading, setLoading] = useState(true);
  useEffect(() => {
    Promise.all(
      CITIES.map(async city => {
        try {
          const d = await fetchWeather(city);
          return { name: city, temp: Math.round(d.main.temp), icon: d.weather[0].icon, desc: d.weather[0].main };
        } catch { return null; }
      })
    ).then(res => { setCities(res.filter(Boolean)); setLoading(false); });
  }, []);

  if (loading) return (
    <div className={styles.card}>
      <div className={styles.title}>World Cities</div>
      <div className={styles.loading}>{[1,2,3,4].map(i => <div key={i} className={styles.skeleton} />)}</div>
    </div>
  );

  return (
    <div className={styles.card}>
      <div className={styles.title}>World Cities</div>
      <div className={styles.list}>
        {cities.map((c, i) => (
          <button key={i} className={`${styles.city} ${currentCity === c.name ? styles.active : ""}`} onClick={() => onSelect(c.name)}>
            <WeatherIcon code={c.icon} size={28} />
            <span className={styles.cityName}>{c.name}</span>
            <span className={styles.cityDesc}>{c.desc}</span>
            <span className={styles.cityTemp}>{c.temp}&deg;</span>
          </button>
        ))}
      </div>
    </div>
  );
}