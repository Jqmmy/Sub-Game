shader_type particles;

uniform sampler2D pos_tex;
uniform sampler2D vel_tex;

uniform int tex_size = 32;
uniform float separation_weight = 1.5;
uniform float alignment_weight = 1.0;
uniform float cohesion_weight = 1.0;
uniform float neighbor_radius = 0.2;
uniform float max_speed = 4.0;

vec2 index_to_uv(int index) {
    int x = index % tex_size;
    int y = index / tex_size;
    return (vec2(float(x), float(y)) + 0.5) / float(tex_size);
}

void process() {
    int idx = PARTICLE_INDEX;
    vec2 uv = index_to_uv(idx);

    vec3 position = texture(pos_tex, uv).xyz;
    vec3 velocity = texture(vel_tex, uv).xyz;

    vec3 separation = vec3(0.0);
    vec3 alignment = vec3(0.0);
    vec3 cohesion = vec3(0.0);
    int count = 0;

    // Sample nearby texels (approximation)
    for (int x = -1; x <= 1; x++) {
        for (int y = -1; y <= 1; y++) {
            vec2 offset = vec2(x, y) / float(tex_size);
            vec3 other_pos = texture(pos_tex, uv + offset).xyz;
            vec3 other_vel = texture(vel_tex, uv + offset).xyz;

            float d = distance(position, other_pos);
            if (d > 0.0 && d < neighbor_radius) {
                separation += normalize(position - other_pos) / d;
                alignment += other_vel;
                cohesion += other_pos;
                count++;
            }
        }
    }

    if (count > 0) {
        alignment /= float(count);
        cohesion = (cohesion / float(count)) - position;
    }

    velocity +=
        separation * separation_weight +
        alignment * alignment_weight +
        cohesion * cohesion_weight;

    // Clamp speed
    float speed = length(velocity);
    if (speed > max_speed) {
        velocity = normalize(velocity) * max_speed;
    }

    VELOCITY = velocity;
}