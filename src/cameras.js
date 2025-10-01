import { useEffect, useState } from 'react';

function Camera() {
  const [nvrs, setNvrs] = useState(null);
  const [camera, setCamera] = useState(null);
  const [selectedNvr, setSelectedNvr] = useState(null);
  const baseUrl = "http://127.0.0.1:5000"; // Add http://

  useEffect(() => {
    const fetchNvr = async () => {
      try {
        const response = await fetch(`${baseUrl}/`); // Fix endpoint
        const data = await response.json();

        if (Array.isArray(data)) {
          setNvrs(data);
        } else {
          console.error("Error: NVR data is not an array");
        }
      } catch (err) {
        console.error("Error fetching NVRs: ", err);
      } finally {
        console.log("Fetch NVR complete");
      }
    };

    fetchNvr();
  }, []); // Empty dependency array to run once

  return (
    <div>
      <h2>NVR & Camera Monitoring</h2>
      {nvrs ? (
        <pre>{JSON.stringify(nvrs, null, 2)}</pre>
      ) : (
        <p>Loading NVRs...</p>
      )}
    </div>
  );
}

export default Camera;
