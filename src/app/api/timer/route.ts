import { NextRequest, NextResponse } from 'next/server';

// In-memory timer state (shared across requests in dev, not persistent)
let timerEnd: number | null = null;
let timerPaused: boolean = true;
let timerRemaining: number = 0; // seconds remaining when paused

// Helper to get remaining seconds
function getRemainingSeconds() {
  if (timerPaused) return timerRemaining;
  if (!timerEnd) return 0;
  const now = Date.now();
  const diff = Math.max(0, Math.floor((timerEnd - now) / 1000));
  return diff;
}

// GET /api/timer?reset=5 (reset timer to 5 minutes)
// GET /api/timer?start (start timer)
// GET /api/timer?stop (stop timer)
export async function GET(req: NextRequest) {
  // Only allow this handler to respond if the path is exactly /api/timer
  const url = new URL(req.url);
  if (!url.pathname.endsWith('/api/timer')) {
    return NextResponse.json({ error: 'Not found' }, { status: 404 });
  }
  const { searchParams } = url;
  const reset = searchParams.get('reset');
  const start = searchParams.has('start');
  const stop = searchParams.has('stop');

  if (reset) {
    const minutes = parseInt(reset, 10);
    if (isNaN(minutes) || minutes <= 0) {
      return NextResponse.json({ error: 'Invalid minutes' }, { status: 400 });
    }
    timerRemaining = minutes * 60;
    timerPaused = true;
    timerEnd = null;
    return NextResponse.json({ remaining: timerRemaining, paused: timerPaused });
  }
  if (start) {
    if (timerPaused && timerRemaining > 0) {
      timerEnd = Date.now() + timerRemaining * 1000;
      timerPaused = false;
    }
    return NextResponse.json({ remaining: getRemainingSeconds(), paused: timerPaused });
  }
  if (stop) {
    if (!timerPaused && timerEnd) {
      timerRemaining = getRemainingSeconds();
      timerPaused = true;
      timerEnd = null;
    }
    return NextResponse.json({ remaining: timerRemaining, paused: timerPaused });
  }
  return NextResponse.json({ remaining: getRemainingSeconds(), paused: timerPaused });
}
