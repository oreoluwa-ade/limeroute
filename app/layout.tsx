import type { Metadata } from "next";
import "./globals.css";
export const metadata: Metadata = { title: "LimeRoute — Link intelligence", description: "Manage, measure and control the links you share." };
export default function RootLayout({ children }: Readonly<{ children: React.ReactNode }>) { return <html lang="en"><body>{children}</body></html>; }
