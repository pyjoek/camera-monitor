// frontend/src/App.js
import { useEffect, useState } from "react";

function App() {
  const [nvrs, setNvrs] = useState([]);
  const [newCamera, setNewCamera] = useState({ name: "", ip: "" });
  const [selectedNvr, setSelectedNvr] = useState(null);
    const [error, setError] = useState(null);

  const [loading, setLoading] = useState(true);
  const baseUrl = "http://localhost:5000";
  
  useEffect((error) => {
    const fetchNvrs = async () => {
      try {
        const res = await fetch(`${baseUrl}/`);
        const data = await res.json();
        if (Array.isArray(data)) {
          setNvrs(data);
        } else {
          console.error("Error fetching NVRs:", error);
          setError("Failed to fetch NVRs.");
        }
      } catch (err) {
        console.error("Error fetching NVRs:", err);
      }finally {
        setLoading(false);
      }
    };
    
    fetchNvrs();
    const interval = setInterval(fetchNvrs, 5000);
    return () => clearInterval(interval);
  }, []);
  
    const addNvr = async (fetchNvrs) => {
      try {
        const res = await fetch(`${baseUrl}/new/nvr`, {
          method: "POST",
          headers: {"Content-Type": "application/json"},
          body: JSON.stringify(nvrs),
        });
        await res.json();
        setNvrs({name: ""})
        fetchNvrs();
      }
      catch (err) {
        console.log("Error adding nvr:", err)
      }
    };
  
    const addCamera = async (fetchNvrs) => {
      if (!selectedNvr) return alert("Select an NVR first");
      if (!newCamera.name || !newCamera.ip) return alert("Fill name & IP");
  
      try {
        const res = await fetch(`http://localhost:5000/nvrs/${selectedNvr}/cameras`, {
          method: "POST",
          headers: { "Content-Type": "application/json" },
          body: JSON.stringify(newCamera, selectedNvr),
        });
        await res.json();
        setNewCamera({ name: "", ip: "" });
        fetchNvrs();
      } catch (err) {
        console.error("Error adding camera:", err);
      }
    };

  return (
    <div style={{ padding: "20px", fontFamily: "Arial" }}>
      <h2>NVR & Camera Monitoring</h2>

      {loading ? (
        <p>Loading...</p>
      ) : error ? (
        <p>{error}</p>
      ) : nvrs.length === 0 ? (
        <p>No NVRs found in the database.</p>
      ) : nvrs.map((nvr) => (
        <div key={nvr.id} style={{ marginBottom: "30px" }}>
          <h3 style={{ color: "#333" }}>{nvr.name}</h3>
          <div
            style={{
              display: "grid",
              gridTemplateColumns: "repeat(auto-fit, minmax(150px, 1fr))",
              gap: "20px",
              marginTop: "10px",
            }}
          >
            {nvr.cameras.map((cam) => (
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

          {/* Add Camera Form for each NVR */}
          <div style={{ marginTop: "15px" }}>
            <input
              type="radio"
              name="nvr"
              value={nvr.id}
              onChange={() => setSelectedNvr(nvr.id)}
            />
            <label style={{ marginLeft: "5px" }}>Select this NVR</label>
          </div>
        </div>
      ))}

      <div style={{
        display: "flex",
        justifyContent: "space-between"
      }}>
        {/* Add NVR form */}
        <div
          style={{
            marginTop: "20px",
            padding: "15px",
            border: "1px solid #ccc",
            borderRadius: "10px",
            width: "300px",
          }}
        >
          <h4>Add New NVR</h4>
          <input
            type="text"
            placeholder="NVR Name"
            value={nvrs.name}
            onChange={(e) => setNvrs({ ...nvrs, name: e.target.value })}
            style={{ width: "100%", marginBottom: "10px", padding: "5px" }}
          />
          <button
            onClick={addNvr}
            style={{
              padding: "8px 12px",
              background: "#007bff",
              color: "white",
              border: "none",
              borderRadius: "6px",
              cursor: "pointer",
            }}
          >
            + Add NVR
          </button>
        </div>
        {/* Add Camera form */}
        <div
          style={{
            marginTop: "20px",
            padding: "15px",
            border: "1px solid #ccc",
            borderRadius: "10px",
            width: "300px",
          }}
        >
          <h4>Add New Camera</h4>
          <input
            type="text"
            placeholder="NVR Name"
            value={newCamera.name}
            onChange={(e) => setNewCamera({ ...newCamera, name: e.target.value })}
            style={{ width: "100%", marginBottom: "10px", padding: "5px" }}
          />
          <input
            type="text"
            placeholder="Camera IP"
            value={newCamera.ip}
            onChange={(e) => setNewCamera({ ...newCamera, ip: e.target.value })}
            style={{ width: "100%", marginBottom: "10px", padding: "5px" }}
          />
          <button
            onClick={addCamera}
            style={{
              padding: "8px 12px",
              background: "#007bff",
              color: "white",
              border: "none",
              borderRadius: "6px",
              cursor: "pointer",
            }}
          >
            + Add Camera
          </button>
        </div>
      </div>

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
