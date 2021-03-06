varying vec2 v_Coordinates;
 
uniform vec2 u_Scale;
uniform sampler2D u_Texture0;
 
uniform sampler2D image;
vec4 FragmentColor;
float offset[3];
float weight[3];

void main(void) {
    //create arrays with buildings and radii
    const int numBuild = 7;
    vec2 buildings[numBuild];
    float rads[numBuild];
    rads[0] = 8.; //mckeldin
    rads[1] = 8.; //pfreddy
    rads[2] = 3.; //south diner
    rads[3] = 1.; //kim
    rads[4] = 8.; //stamp
    rads[5] = 2.; //chem
    rads[6] = 6.; //bus stop
    buildings[0] = vec2(-76.945,38.986);
    buildings[1] = vec2(-76.9457,38.9832);
    buildings[2] = vec2(-76.9437,38.98305);
    buildings[3] = vec2(-76.937915,38.99094);
    buildings[4] = vec2(-76.944882,38.987989);
    buildings[5] = vec2(-76.940122,38.989309);
    buildings[6] = vec2(-76.943845,38.987652);
    //caculate correct distance from the nearest building and select the appropriate radius
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

    //get fragment's texture from uTexture0
    vec4 tex = texture2D(uTexture0, vec2(vTextureCoords.s, vTextureCoords.t));

    //add code to saturate tex vector
    tex = vec4(tex.r, tex.g, tex.b*.75, 1.0);
    
    //calculate luminance to make black and white
    float lum = tex[0]+tex[1]+tex[2];
    lum = lum/3.0;
    vec4 bwTex = vec4(lum, lum, lum, 1.0);

    //mix bw and colored vectors based on a factor
    float fac = clamp(pow(distance, .8)*1500.0*(1./rad), 0.0, 1.0);
    tex = (tex*(1.0-fac))+(bwTex*fac);

    //create a gaussian blur over the entire map
    //source: http://rastergrid.com/blog/2010/09/efficient-gaussian-blur-with-linear-sampling/
    offset[0] = 0.0;
    offset[1] = 1.3846153846;
    offset[2] = 3.2307692308;
    weight[0] = 0.2270270270;
    weight[1] = 0.3162162162;
    weight[2] = 0.0702702703;

    FragmentColor = texture2D( image, vec2(gl_FragCoord)/1024.0 ) * weight[0];
    for (int i=1; i<3; i++) {
        FragmentColor += texture2D( image, ( vec2(gl_FragCoord)+vec2(0.0, offset[i]) )/1024.0 ) * weight[i];
        FragmentColor += texture2D( image, ( vec2(gl_FragCoord)-vec2(0.0, offset[i]) )/1024.0 ) * weight[i];
    }

    //end insertion of gaussian blur
    
    gl_FragColor = tex;
}