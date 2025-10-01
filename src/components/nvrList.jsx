// NvrList.jsx
import React from 'react';
import NvrCard from './NvrCard';

const NvrList = ({ nvrs }) => {
  if (!nvrs || nvrs.length === 0) {
    return <p>No NVRs found.</p>;
  }

  return (
    <div>
      {nvrs.map((nvr) => (
        <NvrCard key={nvr.id} nvr={nvr} />
      ))}
    </div>
  );
};

export default NvrList;
