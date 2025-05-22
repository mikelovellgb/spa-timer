import type { Metadata } from 'next';
import TimerFlip from "./TimerFlip";

export const metadata: Metadata = {
  title: 'Spa Timer',
  description: 'A beautiful flip countdown timer for spa sessions.'
};

export default function Home() {
  return (
    <div style={{ width: '100vw', height: '100vh', background: 'black' }}>
      <main style={{ width: '100vw', height: '100vh' }}>
        <TimerFlip />
      </main>
    </div>
  );
}
