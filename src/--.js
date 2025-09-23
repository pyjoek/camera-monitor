import { useEffect, useState } from "react";

function App() {
  const [cameras, setCameras] = useState([]);

  // Fetch cameras from backend
  const fetchCameras = async () => {
    try {
      const res = await fetch("http://localhost:8000/cameras");
      const data = await res.json();
      setCameras(data);
    } catch (err) {
      console.error("Error fetching cameras:", err);
    }
  };

  useEffect(() => {
    fetchCameras();
    const interval = setInterval(fetchCameras, 5000); // refresh every 5 sec
    return () => clearInterval(interval);
  }, []);

  return (
    <div style={{ padding: "20px", fontFamily: "Arial" }}>
      <h2>Camera Status</h2>
      <div
        style={{
          display: "grid",
          gridTemplateColumns: "repeat(auto-fit, minmax(150px, 1fr))",
          gap: "20px",
          marginTop: "20px",
        }}
      >
        {cameras.map((cam) => (
          <div
            key={cam.id}
            style={{
              backgroundColor: "#fff",
              borderRadius: "12px",
              boxShadow: "0 4px 8px rgba(0,0,0,0.1)",
              padding: "15px",
              textAlign: "center",
            }}
          >
            <h4 style={{ margin: "0 0 10px 0" }}>{cam.name}</h4>
            <span
              style={{
                width: "20px",
                height: "20px",
                display: "inline-block",
                borderRadius: "50%",
                backgroundColor: cam.status === "online" ? "green" : "red",
                animation:
                  cam.status === "online"
                    ? "blink 1s infinite"
                    : "blinkred 1s infinite",
              }}
            ></span>
          </div>
        ))}
      </div>

      {/* blinking animations */}
      <style>{`
        @keyframes blink {
          0% { opacity: 1; }
          50% { opacity: 0.2; }
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
}

export default App;
