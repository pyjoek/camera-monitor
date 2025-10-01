// NvrCard.jsx
import React from 'react';
import CameraCard from './CameraCard';

const NvrCard = ({ nvr }) => {
  return (
    <div style={{ marginBottom: '30px' }}>
      <h2>{nvr.name}</h2>
      <div style={{
        display: 'flex',
        flexWrap: 'wrap',
        gap: '16px',
        marginTop: '10px'
      }}>
        {nvr.cameras.map((cam) => (
          <CameraCard key={cam.id} camera={cam} />
        ))}
      </div>
    </div>
  );
};

export default NvrCard;
