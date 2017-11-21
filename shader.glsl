void main(void) {
    const int numBuild = 3;
    vec2 buildings[numBuild];
    float rads[numBuild];
    rads[0] = 8.;
    rads[1] = 3.;
    rads[2] = 5.;
    buildings[0] = vec2(-76.945,38.986);
    buildings[1] = vec2(-76.9457,38.9832);
    buildings[2] = vec2(-76.9437,38.98305);
    
    float rad = 1.;
    float distance = 100000.;
    for(int i = 0; i<numBuild; i++){
        float dlat = buildings[i].x - vLatLngCoords.x;
        float dlon = buildings[i].y - vLatLngCoords.y;
        float iter_distance = sqrt(dlat*dlat + dlon*dlon);
        if(iter_distance < distance){
            distance = iter_distance;
            rad = rads[i];
        }
    }

    vec4 tex = texture2D(uTexture0, vec2(vTextureCoords.s, vTextureCoords.t));
    float lum = tex[0]+tex[1]+tex[2];
    lum = lum/3.0;
    vec4 bwTex = vec4(lum, lum, lum, 1.0);
    float fac = clamp(pow(distance, .95)*2500.0*(1./rad), 0.0, 1.0);
    tex = (tex*(1.0-fac))+(bwTex*fac);
    
    gl_FragColor = tex;
}