// CameraDashboard.jsx
import React, { useEffect, useState } from 'react';
import NvrList from './NvrList';

const CameraDashboard = () => {
  const [nvrs, setNvrs] = useState([]);
  const [loading, setLoading] = useState(true);
  const [error, setError] = useState(null);
  const baseUrl = 'http://localhost:5000';

  useEffect(() => {
    const fetchNvrs = async () => {
      try {
        const res = await fetch(`${baseUrl}/nvrs`);
        const data = await res.json();

        if (Array.isArray(data)) {
          setNvrs(data);
        } else {
          setError("Invalid data received");
        }
      } catch (err) {
        console.error("Fetch error:", err);
        setError("Failed to load NVRs");
      } finally {
        setLoading(false);
      }
    };

    fetchNvrs();
    const interval = setInterval(fetchNvrs, 5000); // Refresh every 5 seconds
    return () => clearInterval(interval);
  }, []);

  return (
    <div style={{ padding: '2rem', fontFamily: 'Arial, sans-serif' }}>
      <h1>NVR & Camera Dashboard</h1>
      {loading ? <p>Loading...</p> :
        error ? <p style={{ color: 'red' }}>{error}</p> :
          <NvrList nvrs={nvrs} />}
      
      <style>{`
        @keyframes blink {
          0% { opacity: 1; }
          50% { opacity: 0.3; }
          100% { opacity: 1; }
        }

        @keyframes blinkred {
          0% { opacity: 1; }
          50% { opacity: 0.5; }
          100% { opacity: 1; }
        }
      `}</style>
    </div>
  );
};

export default CameraDashboard;
