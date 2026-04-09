"use client";
import WeatherIcon from "./WeatherIcon";
import styles from "./DailyForecast.module.css";

export default function DailyForecast({ days }) {
  const all = days.flatMap(d => [d.min, d.max]);
  const absMin = Math.min(...all);
  const absMax = Math.max(...all);
  return (
    <div className={styles.card}>
      <div className={styles.title}>5-Day Forecast</div>
      <div className={styles.list}>
        {days.map((day, i) => {
          const date = new Date(day.date);
          const label = i === 0 ? "Today" : date.toLocaleDateString("en-US", { weekday: "short" });
          const minPct = absMax === absMin ? 0 : ((day.min - absMin) / (absMax - absMin)) * 100;
          const maxPct = absMax === absMin ? 100 : ((day.max - absMin) / (absMax - absMin)) * 100;
          return (
            <div key={i} className={styles.row} style={{ animationDelay: `${i * 0.08}s` }}>
              <span className={styles.day}>{label}</span>
              <WeatherIcon code={day.weather.icon} size={28} />
              <span className={styles.desc}>{day.weather.description}</span>
              <div className={styles.range}>
                <span className={styles.low}>{day.min}&deg;</span>
                <div className={styles.bar}>
                  <div className={styles.fill} style={{ left: `${minPct}%`, width: `${maxPct - minPct}%` }} />
                </div>
                <span className={styles.high}>{day.max}&deg;</span>
              </div>
            </div>
          );
        })}
      </div>
    </div>
  );
}