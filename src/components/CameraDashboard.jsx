import React, { useEffect, useState } from 'react';
import NvrList from './NvrList';
import AddNvrModal from './AddNvrModal';
import AddCameraModal from './AddCameraModal';

const CameraDashboard = () => {
  const [nvrs, setNvrs] = useState([]);
  const [loading, setLoading] = useState(true);
  const [error, setError] = useState(null);

  const [showNvrModal, setShowNvrModal] = useState(false);
  const [showCameraModal, setShowCameraModal] = useState(false);

  const baseUrl = 'http://localhost:5000';

  const fetchNvrs = async () => {
    try {
      const res = await fetch(`${baseUrl}/`);
      const data = await res.json();
      if (Array.isArray(data)) {
        setNvrs(data);
        setError(null);
      } else {
        setError("Invalid data received");
      }
    } catch (err) {
      setError("Failed to load NVRs");
      console.error(err);
    } finally {
      setLoading(false);
    }
  };

  useEffect(() => {
    fetchNvrs();
    const interval = setInterval(fetchNvrs, 30000);
    return () => clearInterval(interval);
  }, []);

  // Add NVR handler
  const handleAddNvr = async (nvr) => {
    try {
      const res = await fetch(`${baseUrl}/new/nvr`, {
        method: 'POST',
        headers: { 'Content-Type': 'application/json' },
        body: JSON.stringify(nvr),
      });
      if (res.ok) {
        fetchNvrs();
        setShowNvrModal(false);
      } else {
        alert('Failed to add NVR');
      }
    } catch (err) {
      alert('Error adding NVR');
      console.error(err);
    }
  };

  // Add Camera handler
  const handleAddCamera = async ({ name, ip, nvrId }) => {
    try {
      const res = await fetch(`${baseUrl}/nvrs/${nvrId}/cameras`, {
        method: 'POST',
        headers: { 'Content-Type': 'application/json' },
        body: JSON.stringify({ name, ip }),
      });
      if (res.ok) {
        fetchNvrs();
        setShowCameraModal(false);
      } else {
        alert('Failed to add camera');
      }
    } catch (err) {
      alert('Error adding camera');
      console.error(err);
    }
  };

  return (
    <div style={{ padding: '2rem', fontFamily: 'Arial, sans-serif' }}>
      <h1>NVR & Camera Dashboard</h1>

      <div style={{ marginBottom: '20px', display: 'flex', gap: '15px' }}>
        <button
          onClick={() => setShowNvrModal(true)}
          style={btnStyle}
        >
          + Add NVR
        </button>
        <button
          onClick={() => setShowCameraModal(true)}
          style={btnStyle}
          disabled={nvrs.length === 0}
          title={nvrs.length === 0 ? "Add an NVR first" : ""}
        >
          + Add Camera
        </button>
      </div>

      {loading ? <p>Loading...</p> :
        error ? <p style={{ color: 'red' }}>{error}</p> :
          <NvrList nvrs={nvrs} />
      }

      <AddNvrModal
        isOpen={showNvrModal}
        onClose={() => setShowNvrModal(false)}
        onAdd={handleAddNvr}
      />

      <AddCameraModal
        isOpen={showCameraModal}
        onClose={() => setShowCameraModal(false)}
        onAdd={handleAddCamera}
        nvrList={nvrs}
      />

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

const btnStyle = {
  padding: '10px 20px',
  fontSize: '16px',
  backgroundColor: '#007bff',
  border: 'none',
  borderRadius: '6px',
  color: '#fff',
  cursor: 'pointer',
};

export default CameraDashboard;
