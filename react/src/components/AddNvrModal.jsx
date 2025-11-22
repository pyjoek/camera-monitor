import React, { useState } from 'react';

const AddNvrModal = ({ isOpen, onClose, onAdd }) => {
  const [name, setName] = useState('');

  if (!isOpen) return null;

  const handleSubmit = (e) => {
    e.preventDefault();
    if (!name.trim()) return alert("Please enter NVR name");
    onAdd({ name });
    setName('');
  };

  return (
    <div style={modalOverlayStyle}>
      <div style={modalStyle}>
        <h3>Add New NVR</h3>
        <form onSubmit={handleSubmit}>
          <input
            type="text"
            placeholder="NVR Name"
            value={name}
            onChange={(e) => setName(e.target.value)}
            style={{ width: '100%', padding: '8px', marginBottom: '12px' }}
          />
          <div style={{ display: 'flex', justifyContent: 'flex-end', gap: '10px' }}>
            <button type="button" onClick={onClose} style={btnCancelStyle}>Cancel</button>
            <button type="submit" style={btnSubmitStyle}>Add NVR</button>
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

export default AddNvrModal;
