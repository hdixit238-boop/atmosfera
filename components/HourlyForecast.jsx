"use client";
import WeatherIcon from "./WeatherIcon";
import styles from "./HourlyForecast.module.css";

export default function HourlyForecast({ hours }) {
  const maxTemp = Math.max(...hours.map(h => h.temp));
  const minTemp = Math.min(...hours.map(h => h.temp));
  return (
    <div className={styles.card}>
      <div className={styles.title}>Hourly Forecast</div>
      <div className={styles.scroll}>
        {hours.map((h, i) => {
          const pct = maxTemp === minTemp ? 50 : ((h.temp - minTemp) / (maxTemp - minTemp)) * 100;
          return (
            <div key={i} className={styles.item} style={{ animationDelay: `${i * 0.06}s` }}>
              <div className={styles.time}>{i === 0 ? "Now" : h.time}</div>
              {h.pop > 0 && <div className={styles.pop}>{h.pop}%</div>}
              <WeatherIcon code={h.weather.icon} size={32} />
              <div className={styles.bar}>
                <div className={styles.barFill} style={{ height: `${pct}%` }} />
              </div>
              <div className={styles.temp}>{h.temp}&deg;</div>
            </div>
          );
        })}
      </div>
    </div>
  );
}