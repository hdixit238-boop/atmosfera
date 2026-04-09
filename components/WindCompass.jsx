"use client";
import { getWindDirection } from "@/lib/weather";
import styles from "./WindCompass.module.css";
function getBeaufort(mps){
  const s=[{max:0.5,level:0,name:"Calm",color:"#68d391"},{max:1.5,level:1,name:"Light Air",color:"#68d391"},{max:3.3,level:2,name:"Light Breeze",color:"#90cdf4"},{max:5.5,level:3,name:"Gentle Breeze",color:"#63b3ed"},{max:7.9,level:4,name:"Moderate Breeze",color:"#f5c842"},{max:10.7,level:5,name:"Fresh Breeze",color:"#f5c842"},{max:13.8,level:6,name:"Strong Breeze",color:"#fc8181"},{max:17.1,level:7,name:"Near Gale",color:"#fc8181"},{max:20.7,level:8,name:"Gale",color:"#b794f4"},{max:24.4,level:9,name:"Strong Gale",color:"#b794f4"},{max:28.4,level:10,name:"Storm",color:"#fc8181"},{max:32.6,level:11,name:"Violent Storm",color:"#fc8181"},{max:Infinity,level:12,name:"Hurricane",color:"#fc8181"}];
  return s.find(x=>mps<=x.max)||s[s.length-1];
}
export default function WindCompass({data}){
  const speed=Math.round(data.wind.speed);
  const deg=data.wind.deg||0;
  const gust=data.wind.gust?Math.round(data.wind.gust):null;
  const dir=getWindDirection(deg);
  const b=getBeaufort(speed);
  return(
    <div className={styles.card}>
      <div className={styles.title}>Wind</div>
      <div className={styles.body}>
        <div className={styles.compassWrap}>
          <div className={styles.compass}>
            {["N","E","S","W"].map(d=><span key={d} className={styles["dir"+d]}>{d}</span>)}
            <div className={styles.needle} style={{transform:`rotate(${deg}deg)`}}>
              <div className={styles.needleHead}/>
              <div className={styles.needleTail}/>
            </div>
            <div className={styles.center}/>
          </div>
        </div>
        <div className={styles.info}>
          <div className={styles.speedBlock}>
            <div className={styles.speed}>{speed}</div>
            <div className={styles.unit}>m/s</div>
          </div>
          <div className={styles.direction}>{dir} Â· {deg}Â°</div>
          {gust&&<div className={styles.gust}>Gust: {gust} m/s</div>}
          <div className={styles.beaufort}>
            <div className={styles.beaufortLabel}>Beaufort Scale</div>
            <div className={styles.beaufortBar}>
              {Array.from({length:12}).map((_,i)=><div key={i} className={styles.beaufortCell} style={{background:i<b.level?b.color:"rgba(255,255,255,0.08)"}}/>)}
            </div>
            <div className={styles.beaufortName} style={{color:b.color}}>{b.name}</div>
          </div>
        </div>
      </div>
    </div>
  );
}
