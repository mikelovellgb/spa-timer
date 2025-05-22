import type { Metadata } from 'next';
import TimerFlip from "./TimerFlip";

export const metadata: Metadata = {
  title: 'Spa Timer',
  description: 'A beautiful flip countdown timer for spa sessions.'
};

export default function Home() {
  return (
    <div className="min-h-screen flex flex-col items-center justify-center bg-white dark:bg-black">
      <main className="flex flex-col gap-8 items-center justify-center w-full">
        <TimerFlip />
      </main>
    </div>
  );
}
