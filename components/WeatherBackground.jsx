"use client";
import styles from "./WeatherBackground.module.css";
const themes = {
  clear:   { gradient: "linear-gradient(160deg,#0f2027 0%,#1a3a5c 40%,#2c5f8a 100%)", accent: "#f5c842", particles: "stars" },
  clouds:  { gradient: "linear-gradient(160deg,#0a0e1a 0%,#1a2235 50%,#243347 100%)", accent: "#90cdf4", particles: "none" },
  rain:    { gradient: "linear-gradient(160deg,#0a0c14 0%,#111827 50%,#1a2235 100%)", accent: "#63b3ed", particles: "rain" },
  drizzle: { gradient: "linear-gradient(160deg,#0a0e1a 0%,#111827 50%,#1a2235 100%)", accent: "#76e4f7", particles: "rain" },
  storm:   { gradient: "linear-gradient(160deg,#05060a 0%,#0d1117 50%,#111827 100%)", accent: "#b794f4", particles: "storm" },
  snow:    { gradient: "linear-gradient(160deg,#0d1117 0%,#1a2235 50%,#243347 100%)", accent: "#bee3f8", particles: "snow" },
  fog:     { gradient: "linear-gradient(160deg,#111827 0%,#1f2937 50%,#243347 100%)", accent: "#a0aec0", particles: "none" },
};
function Stars() {
  return (
    <div className={styles.stars}>
      {Array.from({length:60}).map((_,i) => (
        <div key={i} className={styles.star} style={{left:`${Math.random()*100}%`,top:`${Math.random()*100}%`,animationDelay:`${Math.random()*4}s`,animationDuration:`${2+Math.random()*3}s`,width:`${Math.random()*2.5+0.5}px`,height:`${Math.random()*2.5+0.5}px`}} />
      ))}
    </div>
  );
}
function Rain() {
  return (
    <div className={styles.rain}>
      {Array.from({length:40}).map((_,i) => (
        <div key={i} className={styles.raindrop} style={{left:`${Math.random()*100}%`,animationDelay:`${Math.random()*2}s`,animationDuration:`${0.6+Math.random()*0.6}s`,opacity:0.15+Math.random()*0.25}} />
      ))}
    </div>
  );
}
function Snow() {
  return (
    <div className={styles.snow}>
      {Array.from({length:40}).map((_,i) => (
        <div key={i} className={styles.flake} style={{left:`${Math.random()*100}%`,animationDelay:`${Math.random()*5}s`,animationDuration:`${4+Math.random()*4}s`,width:`${Math.random()*6+2}px`,height:`${Math.random()*6+2}px`,opacity:0.3+Math.random()*0.4}} />
      ))}
    </div>
  );
}
export default function WeatherBackground({ theme = "clear" }) {
  const t = themes[theme] || themes.clear;
  return (
    <div className={styles.bg} style={{background: t.gradient}}>
      <div className={styles.orb1} style={{background:`radial-gradient(circle,${t.accent}22 0%,transparent 70%)`}} />
      <div className={styles.orb2} style={{background:`radial-gradient(circle,${t.accent}11 0%,transparent 70%)`}} />
      <div className={styles.noise} />
      {t.particles === "stars" && <Stars />}
      {(t.particles === "rain" || t.particles === "storm") && <Rain />}
      {t.particles === "snow" && <Snow />}
    </div>
  );
}
