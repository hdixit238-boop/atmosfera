import "./globals.css";
export const metadata = { title: "Aether Weather", description: "Beautiful real-time weather app" };
export default function RootLayout({ children }) {
  return <html lang="en"><body>{children}</body></html>;
}
