// CameraCard.jsx
import React from 'react';

const CameraCard = ({ camera }) => {
  const { name, ip, status } = camera;

  const getStatusColor = () => {
    if (status === 'online') return 'green';
    if (status === 'offline') return 'red';
    return 'gray';
  };

  const getAnimation = () => {
    if (status === 'online') return 'blink';
    if (status === 'offline') return 'blinkred';
    return 'none';
  };

  return (
    <div style={{
      border: '1px solid #ddd',
      borderRadius: '8px',
      padding: '15px',
      width: '220px',
      backgroundColor: '#f9f9f9',
      boxShadow: '0 2px 4px rgba(0,0,0,0.1)'
    }}>
      <h4 style={{ marginBottom: '8px' }}>{name}</h4>
      <p style={{ margin: '4px 0' }}><strong>IP:</strong> {ip}</p>
      <p style={{ margin: '4px 0' }}><strong>Status:</strong> <span style={{ color: getStatusColor(), fontWeight: 'bold' }}>{status}</span></p>
      <div style={{ marginTop: '8px' }}>
        <span
          title={`Status: ${status}`}
          style={{
            width: '14px',
            height: '14px',
            borderRadius: '50%',
            display: 'inline-block',
            backgroundColor: getStatusColor(),
            animation: `${getAnimation()} 1s infinite`
          }}
        ></span>
      </div>
    </div>
  );
};

export default CameraCard;
