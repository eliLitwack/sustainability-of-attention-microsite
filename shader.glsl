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
    #define gauss_width 7
    int sumr=0, sumg=0, sumb=0;
    int gauss_fact[gauss_width];
    gauss_fact[0]=1;
    gauss_fact[1]=6;
    gauss_fact[2]=15;
    gauss_fact[3]=20;
    gauss_fact[4]=15;
    gauss_fact[5]=6;
    gauss_fact[6]=1;
    int gauss_sum=64;
    int w = int(vTextureCoords.x);
    int h = int(vTextureCoords.y);
 
    for(int i=1;i<w-1;i++){
      for(int j=1;j<h-1;j++){
        sumr=0;
        sumg=0;
        sumb=0;
        for(int k=0;k<gauss_width;k++){    
          color=getpixel(temp,i-((gauss_width-1)>>1)+k,j);
          r=getr32(color);
          g=getg32(color);
          b=getb32(color);
          sumr+=r*gauss_fact[k];
          sumg+=g*gauss_fact[k];
          sumb+=b*gauss_fact[k];
        }
        putpixel(temp1,i,j,makecol(sumr/gauss_sum,sumg/gauss_sum, sumb/gauss_sum));
      } 
    }
 
    for(int i=1;i<w-1;i++){
      for(int j=1;j<h-1;j++){
        sumr=0;
        sumg=0;
        sumb=0;
        for(int k=0;k<gauss_width;k++){
          color=getpixel(temp1,i,j-((gauss_width-1)>>1)+k);
          r=getr32(color);
          g=getg32(color);
          b=getb32(color);
          sumr+=r*gauss_fact[k];
          sumg+=g*gauss_fact[k];
          sumb+=b*gauss_fact[k];
        }
        sumr/=gauss_sum;
        sumg/=gauss_sum;
        sumb/=gauss_sum;
        putpixel(temp2,i,j,makecol(sumr,sumg,sumb));
      } 
    }
    //end insertion of gaussian blur
    
    gl_FragColor = tex;
}