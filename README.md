# HB-Calculator
Hydrualic Bearing calculator

$$
\frac{\partial}{\partial\theta} \left[ \left( 1 + \varepsilon \cos\theta \right)^3 \frac{\partial p}{\partial\theta} \right] + \left( \frac{D}{L} \right)^2 \left( 1 + \varepsilon \cos\theta \right)^3 \frac{\partial^2 p}{\partial \left( \frac{x}{L/2} \right)^2} = - \frac{6\mu\Omega R^2}{(R-R_I)^2} \varepsilon \sin\theta
$$

$$
p(\theta, x=\pm L/2) = p_a \quad\quad p(\theta,x) = p(\theta + 2\pi, x)
$$

$$
\varphi = \frac{(p-p_a)(R-R_I)^2}{6\mu\Omega R^2 \varepsilon} \quad\quad \eta = \frac{x}{L/2} \quad\quad \Lambda = \frac{L}{D}
$$

$$
\frac{\partial}{\partial\theta} \left[ \left( 1 + \varepsilon \cos\theta \right)^3 \frac{\partial\varphi}{\partial\theta} \right] + \frac{\left( 1 + \varepsilon \cos\theta \right)^3 }{\Lambda^2}\frac{\partial^2 \varphi}{\partial\eta^2} = -\sin\theta
$$

$$
\varphi(\theta, \eta=\pm 1) = 0 \quad\quad \varphi(\theta,\eta) = p(\theta + 2\pi, \eta)
$$
