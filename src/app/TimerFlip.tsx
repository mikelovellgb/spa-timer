'use client';
import '@pqina/flip/dist/flip.min.css';
import { useEffect, useRef, useState } from 'react';
import styles from './TimerFlip.module.css';

export default function TimerFlip() {
  const tickRef = useRef<HTMLDivElement>(null);
  const tickInstance = useRef<unknown>(null);
  const [seconds, setSeconds] = useState<number>(0);
  const [paused, setPaused] = useState<boolean>(false);
  const [tickLoaded, setTickLoaded] = useState<boolean>(false);
  const [roomName, setRoomName] = useState<string>("");

  async function fetchTime() {
    const res = await fetch('/api/timer');
    const data = await res.json();
    setSeconds(data.remaining);
    setPaused(!!data.paused);
  }

  useEffect(() => {
    fetchTime();
    const interval = setInterval(fetchTime, 1000);
    return () => clearInterval(interval);
  }, []);

  useEffect(() => {
    fetch('/room.json')
      .then((res) => res.json())
      .then((data) => setRoomName(data.roomName || ''));
  }, []);

  useEffect(() => {
    let isMounted = true;
    let localTickInstance: unknown = null;
    // Only create the Tick instance once, on mount
    import('@pqina/flip').then((Tick) => {
      const dom =
        (Tick && 'DOM' in Tick && (Tick as Record<string, unknown>).DOM) ||
        (Tick && Tick.default && 'DOM' in Tick.default && (Tick.default as Record<string, unknown>).DOM);
      if (!dom) {
        console.error('Tick.DOM is undefined after import:', Tick);
        return;
      }
      if (isMounted && tickRef.current && !tickInstance.current) {
        // Use 00:00 as the initial value to avoid referencing 'seconds' in this effect
        localTickInstance = dom.create(tickRef.current, { value: formatTime(0) });
        tickInstance.current = localTickInstance;
        setTickLoaded(true);
        console.log('Tick instance created and setTickLoaded(true) called');
      }
    }).catch((err) => {
      console.error('Error importing @pqina/flip:', err);
    });
    return () => {
      isMounted = false;
      if (
        tickInstance.current &&
        typeof tickInstance.current === 'object' &&
        tickInstance.current !== null &&
        'destroy' in tickInstance.current &&
        typeof (tickInstance.current as Record<string, unknown>).destroy === 'function'
      ) {
        (tickInstance.current as { destroy: () => void }).destroy();
        tickInstance.current = null;
        console.log('Tick instance destroyed');
      }
    };
  }, []); // Only run on mount/unmount

  // Format seconds as mm:ss
  function formatTime(s: number) {
    const m = Math.floor(s / 60).toString().padStart(2, '0');
    const sec = (s % 60).toString().padStart(2, '0');
    return `${m}:${sec}`;
  }

  useEffect(() => {
    if (
      tickInstance.current &&
      typeof tickInstance.current === 'object' &&
      tickInstance.current !== null &&
      'value' in tickInstance.current
    ) {
      // Set formatted mm:ss string as value
      (tickInstance.current as { value: string }).value = formatTime(seconds);
    }
  }, [seconds]); 

  return (
    <div style={{ width: '100vw', height: '100vh', position: 'relative', display: 'flex', alignItems: 'center', justifyContent: 'center' }}>
      {/* Centered logo, only visible when timer is zero or paused */}
      <div
        style={{
          display: (seconds === 0 || paused) ? 'flex' : 'none',
          alignItems: 'center',
          justifyContent: 'center',
          width: '100vw',
          height: '100vh',
          position: 'absolute',
          top: 0,
          left: 0,
          background: 'black',
          zIndex: 2,
        }}
      >
        <img
          src="/xf_gym_logo.jpg"
          alt="Logo"
          style={{
            maxWidth: '40vw',
            maxHeight: '40vh',
            objectFit: 'contain',
            display: 'block',
            margin: '0 auto',
          }}
        />
      </div>

      {/* Timer/room layout, only visible when timer is running and not paused */}
      <div
        className={styles.timerRoomLayout}
        style={{ display: (seconds > 0 && !paused) ? 'flex' : 'none', position: 'absolute', top: 0, left: 0, width: '100vw', height: '100vh', background: 'black', zIndex: 1 }}
      >
        {/* Left column: logo and room name, room name right-aligned and vertically centered between logo and timer */}
        <div style={{
          display: 'flex', flexDirection: 'column', alignItems: 'flex-end', justifyContent: 'center',
          width: '22vw', minWidth: '18vw', maxWidth: '30vw', paddingRight: '2vw',
        }}>
          <img src="/xf_gym_logo.jpg" alt="Logo" style={{ maxWidth: '18vw', maxHeight: '18vh', objectFit: 'contain', display: 'block', marginBottom: '2vh' }} />
          <div style={{
            fontSize: '2vw', fontWeight: 'bold', textAlign: 'right', color: '#44ff68', width: '100%', paddingRight: '0.5vw',
          }}>{roomName}</div>
        </div>
        {/* Timer */}
        <div
          ref={tickRef}
          className="tick custom-flip-dark"
          style={{
            display: tickLoaded ? 'flex' : 'none',
            alignItems: 'center',
            justifyContent: 'center',
            fontSize: '9vw',
            minWidth: '20vw',
            maxWidth: '60vw',
            minHeight: '12vh',
            maxHeight: '24vh',
            marginLeft: '4vw',
          }}
        >
          <div data-repeat="true" aria-hidden="true">
            <span data-view="flip">Tick</span>
          </div>
        </div>
      </div>
      {tickLoaded && !tickInstance.current && (
        <div style={{ textAlign: 'center', color: 'red', marginTop: 16 }}>
          Timer failed to load. Please check Tick/Flip setup.
        </div>
      )}
    </div>
  );
}