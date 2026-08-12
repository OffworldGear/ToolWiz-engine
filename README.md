# ToolWiz Engine (OG-MOE)

ToolWiz Engine is a high-performance, web-based CNC Speeds and Feeds Optimization Engine designed for the Brother Speedio S500X2. It reverse-engineers the core physics and materials logic of industry-standard calculators (like GWizard) and combines them with a beautiful, responsive, and dynamic UI for real-time machining parameter optimization.

## 🚀 Features

- **Advanced Physics Engine**: Implements exact multipliers for 14+ tool types (Roughers, Parabolic Drills, T-Slots, Dovetails, Keyseats, etc.) to accurately determine baseline SFM (Surface Feet per Minute) and IPT (Inch per Tooth).
- **Dynamic Deflection & Power Limits**: Iteratively solves for the safest maximum Depth of Cut (DOC) and Width of Cut (WOC) based on a 10 HP spindle limit and strict tool deflection thresholds.
- **Smart Tool Geometries**: Automatically constraints specific tool types (like T-Slot cutters) to their physical dimensions, locking DOC to the precise Cutter Thickness to prevent breakages.
- **Micro-Tool Guards**: Prevents rubbing and ploughing in tough materials by ensuring feed per tooth never drops below the cutting edge radius.
- **Chip Thinning Adjustments**: Integrates Radial Chip Thinning Factor (RCTF) for light stepovers, optimizing feed rates to maintain chip thickness and heat dissipation.
- **Aggressiveness Scaling**: Features a "Tortoise to Hare" slider that directly scales the aggressiveness of the cut while safely padding Deflection limits.
- **Auto-Set Recommendations**: A one-click `Auto-Set Slider Dials` button injects the calculated optimal safe max cut parameters straight into your manual tuning inputs.
- **Premium Glassmorphism UI**: Wide, desktop-first UI with responsive numeric bindings inside the sliders, entirely avoiding the need to scroll.

## 🛠️ Installation & Setup

1. **Clone the repository**:
   ```bash
   git clone https://github.com/OffworldGear/ToolWiz-engine.git
   cd ToolWiz-engine
   ```

2. **Install Dependencies**:
   Ensure you have Python installed, then install the Flask backend requirements:
   ```bash
   pip install flask
   ```
   *(Note: No other external libraries are strictly required for the core physics engine as it relies on standard Python math modules).*

3. **Run the Engine**:
   Start the local Flask development server:
   ```bash
   python app.py
   ```

4. **Access the Interface**:
   Open your browser and navigate to:
   ```
   http://127.0.0.1:5000/
   ```

## 🧠 How to Use

1. **Select Tool Geometry**: Choose your cutter type (Square, Ball, T-Slot, Dovetail, etc.) from the dropdown. The UI will dynamically expand to request necessary measurements (e.g., Neck Diameter, Flute Length, Cutter Thickness).
2. **Set Parameters**: Slide or explicitly type your tool measurements (Diameter, Flutes, Cut Depth, Cut Width, Stickout) into the fields.
3. **Tune Aggressiveness**: Slide the Aggressiveness meter to dial in the speed.
4. **Read Output**: The engine instantly updates the RPM, Feedrate (IPM), Material Removal Rate (MRR), and Deflection.
5. **Apply Recommendations**: If your inputs are inefficient or unsafe, click the **Auto-Set Slider Dials** button under the `Recommended Max Cut` box to automatically pull in the absolute best physics-based cut depth and width.

## ⚙️ Architecture

*   **`gwizard_physics.py`**: The core algorithmic backbone. Evaluates deflection cantilevers, chip thinning curves, micro-tool boundaries, and dynamic ramping angles.
*   **`app.py`**: A lightweight Flask API that bridges frontend parameter inputs to the backend physics engine.
*   **`templates/index.html` & `static/style.css`**: The dark-mode, glassmorphism UI offering fluid DOM updates via JavaScript.
*   **`test_benchmarks.py`**: An automated testing suite that validates the physics engine's output against strict standard recommendations from the Harvey Tool and Valor catalogs.
