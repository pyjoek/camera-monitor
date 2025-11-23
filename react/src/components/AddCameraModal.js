import React, { useState } from 'react';

const AddCameraModal = ({ isOpen, onClose, onAdd, nvrList }) => {
  const [name, setName] = useState('');
  const [ip, setIp] = useState('');
  const [selectedNvrId, setSelectedNvrId] = useState(nvrList.length > 0 ? nvrList[0].id : "");

  if (!isOpen) return null;

  const handleSubmit = (e) => {
    e.preventDefault();
    if (!name.trim() || !ip.trim()) return alert("Please enter camera name and IP");
    if (!selectedNvrId) return alert("Please select an NVR");
    onAdd({ name, ip, nvrId: selectedNvrId });
    setName('');
    setIp('');
  };

  return (
    <div style={modalOverlayStyle}>
      <div style={modalStyle}>
        <h3>Add New Camera</h3>
        <form onSubmit={handleSubmit}>
          <label style={{ display: 'block', marginBottom: '6px' }}>Select NVR:</label>
          <select
            value={selectedNvrId}
            onChange={(e) => setSelectedNvrId(parseInt(e.target.value))}
            style={{ width: '100%', padding: '8px', marginBottom: '12px' }}
          >
            <option value="" disabled>Select NVR</option>
            {nvrList.map(nvr => (
              <option key={nvr.id} value={nvr.id}>{nvr.name}</option>
            ))}
          </select>

          <input
            type="text"
            placeholder="Camera Name"
            value={name}
            onChange={(e) => setName(e.target.value)}
            style={{ width: '100%', padding: '8px', marginBottom: '12px' }}
          />
          <input
            type="text"
            placeholder="Camera IP"
            value={ip}
            onChange={(e) => setIp(e.target.value)}
            style={{ width: '100%', padding: '8px', marginBottom: '12px' }}
          />
          <div style={{ display: 'flex', justifyContent: 'flex-end', gap: '10px' }}>
            <button type="button" onClick={onClose} style={btnCancelStyle}>Cancel</button>
            <button type="submit" style={btnSubmitStyle}>Add Camera</button>
          </div>
        </form>
      </div>
    </div>
  );
};

const modalOverlayStyle = {
  position: 'fixed', top: 0, left: 0, right: 0, bottom: 0,
  backgroundColor: 'rgba(0,0,0,0.3)', display: 'flex',
  justifyContent: 'center', alignItems: 'center', zIndex: 1000
};

const modalStyle = {
  backgroundColor: '#fff',
  padding: '20px',
  borderRadius: '8px',
  width: '320px',
  boxShadow: '0 4px 12px rgba(0,0,0,0.15)'
};

const btnCancelStyle = {
  background: '#ccc',
  border: 'none',
  padding: '8px 15px',
  borderRadius: '5px',
  cursor: 'pointer'
};

const btnSubmitStyle = {
  background: '#007bff',
  border: 'none',
  padding: '8px 15px',
  borderRadius: '5px',
  color: 'white',
  cursor: 'pointer'
};

export default AddCameraModal;
