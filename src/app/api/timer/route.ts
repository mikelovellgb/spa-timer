import { NextRequest, NextResponse } from 'next/server';

// In-memory timer state (shared across requests in dev, not persistent)
let timerEnd: number | null = null;

// Helper to get remaining seconds
function getRemainingSeconds() {
  if (!timerEnd) return 0;
  const now = Date.now();
  const diff = Math.max(0, Math.floor((timerEnd - now) / 1000));
  return diff;
}

// GET /api/timer?reset=5 (reset timer to 5 minutes)
export async function GET(req: NextRequest) {
  const { searchParams } = new URL(req.url);
  const reset = searchParams.get('reset');
  if (reset) {
    const minutes = parseInt(reset, 10);
    if (isNaN(minutes) || minutes <= 0) {
      return NextResponse.json({ error: 'Invalid minutes' }, { status: 400 });
    }
    timerEnd = Date.now() + minutes * 60 * 1000;
  }
  return NextResponse.json({ remaining: getRemainingSeconds() });
}
