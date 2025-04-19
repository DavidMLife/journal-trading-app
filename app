import React, { useState, useEffect } from 'react';
import { LineChart, Line, CartesianGrid, XAxis, YAxis, Tooltip } from 'recharts';

function App() {
  const [trades, setTrades] = useState(() => JSON.parse(localStorage.getItem('trades')) || []);
  const [form, setForm] = useState({ date: '', asset: '', entry: '', exit: '', size: '', direction: 'Buy' });
  const [calc, setCalc] = useState({ entry: '', exit: '', size: '', direction: 'Buy', result: null });

  useEffect(() => {
    localStorage.setItem('trades', JSON.stringify(trades));
  }, [trades]);

  const addTrade = () => {
    if (!form.date || !form.asset || !form.entry || !form.exit || !form.size) return;
    const pnl = (form.direction === 'Buy'
      ? (form.exit - form.entry)
      : (form.entry - form.exit)) * form.size;
    setTrades([...trades, { ...form, pnl }]);
    setForm({ date: '', asset: '', entry: '', exit: '', size: '', direction: 'Buy' });
  };

  const calculatePnL = () => {
    const entry = parseFloat(calc.entry);
    const exit = parseFloat(calc.exit);
    const size = parseFloat(calc.size);
    if (isNaN(entry) || isNaN(exit) || isNaN(size)) return;
    const result = (calc.direction === 'Buy' ? (exit - entry) : (entry - exit)) * size;
    setCalc({ ...calc, result });
  };

  const chartData = trades.map((t, i) => ({
    name: t.date,
    PnL: trades.slice(0, i + 1).reduce((acc, curr) => acc + curr.pnl, 0)
  }));

  return (
    <div>
      <h1>Journal de Trading</h1>
      <input placeholder="Date" value={form.date} onChange={e => setForm({ ...form, date: e.target.value })} />
      <input placeholder="Asset" value={form.asset} onChange={e => setForm({ ...form, asset: e.target.value })} />
      <input placeholder="Entry" type="number" value={form.entry} onChange={e => setForm({ ...form, entry: parseFloat(e.target.value) })} />
      <input placeholder="Exit" type="number" value={form.exit} onChange={e => setForm({ ...form, exit: parseFloat(e.target.value) })} />
      <input placeholder="Size" type="number" value={form.size} onChange={e => setForm({ ...form, size: parseFloat(e.target.value) })} />
      <select value={form.direction} onChange={e => setForm({ ...form, direction: e.target.value })}>
        <option>Buy</option>
        <option>Sell</option>
      </select>
      <button onClick={addTrade}>Ajouter</button>

      <h2>Calculatrice de Trade</h2>
      <input placeholder="Entry" type="number" value={calc.entry} onChange={e => setCalc({ ...calc, entry: e.target.value })} />
      <input placeholder="Exit" type="number" value={calc.exit} onChange={e => setCalc({ ...calc, exit: e.target.value })} />
      <input placeholder="Size" type="number" value={calc.size} onChange={e => setCalc({ ...calc, size: e.target.value })} />
      <select value={calc.direction} onChange={e => setCalc({ ...calc, direction: e.target.value })}>
        <option>Buy</option>
        <option>Sell</option>
      </select>
      <button onClick={calculatePnL}>Calculer</button>
      {calc.result !== null && <p>Résultat du trade : {calc.result.toFixed(2)}</p>}

      <table>
        <thead>
          <tr><th>Date</th><th>Asset</th><th>Entry</th><th>Exit</th><th>Size</th><th>Dir</th><th>PnL</th></tr>
        </thead>
        <tbody>
          {trades.map((t, i) => (
            <tr key={i}><td>{t.date}</td><td>{t.asset}</td><td>{t.entry}</td><td>{t.exit}</td><td>{t.size}</td><td>{t.direction}</td><td>{t.pnl.toFixed(2)}</td></tr>
          ))}
        </tbody>
      </table>

      <LineChart width={600} height={300} data={chartData}>
        <Line type="monotone" dataKey="PnL" stroke="#8884d8" />
        <CartesianGrid stroke="#ccc" />
        <XAxis dataKey="name" />
        <YAxis />
        <Tooltip />
      </LineChart>
    </div>
  );
}

export default App;
