import React, { useEffect, useState } from 'react';

function NVR() {
    const [nvr, setNvr] = useState(null);
    const [loading, setLoading] = useState(true);
    const [error, setError] = useState(null);

    const fetchNvr = async () => {
        try{
            const response = await fetch('http://127.0.0.1:5000/nvr');

            if (!response.ok) {
                throw new Error(`Http error! status: ${response.status}`);
            }

            const data = await response.json()
            setNvr(data);
        }catch (err) {
            setError(err.message);
        } finally {
            setLoading(false);
        }
    };

    useEffect(() => {
        fetchNvr();
    }, []);

    if (loading) return <p>Loading NVR...</p>
    if (error) return <p>Error: {error}</p>

    return (
        <div>
            <h2>NVR</h2>
            <pre>{JSON.stringify(nvr, null, 2)}</pre>
        </div>
    )
}

export default NVR