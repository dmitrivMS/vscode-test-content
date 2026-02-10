import React, { useState, useEffect } from 'react';

function SearchBar({ onSearch }) {
    const [query, setQuery] = useState('');
    const [results, setResults] = useState([]);
    const [loading, setLoading] = useState(false);

    useEffect(() => {
        if (query.length < 2) {
            setResults([]);
            return;
        }
        const timer = setTimeout(async () => {
            setLoading(true);
            const res = await fetch(`/api/search?q=${encodeURIComponent(query)}`);
            const data = await res.json();
            setResults(data.items);
            setLoading(false);
        }, 300);
        return () => clearTimeout(timer);
    }, [query]);

    return (
        <div className="search-container">
            <input
                type="text"
                value={query}
                onChange={(e) => setQuery(e.target.value)}
                placeholder="Search..."
            />
            {loading && <span className="spinner" />}
            <ul className="results">
                {results.map((item) => (
                    <li key={item.id} onClick={() => onSearch(item)}>
                        {item.title}
                    </li>
                ))}
            </ul>
        </div>
    );
}

export default SearchBar;
