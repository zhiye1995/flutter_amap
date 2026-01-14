package com.amap.map3d.demo.opengl.cube;

import android.opengl.GLES20;
import android.opengl.Matrix;

import java.nio.ByteBuffer;
import java.nio.ByteOrder;
import java.nio.FloatBuffer;
import java.nio.ShortBuffer;
import java.util.ArrayList;

class Cube {
    ArrayList<Float> verticesList = new ArrayList<Float>();

    short indices[] = {
            0, 4, 5,
            0, 5, 1,
            1, 5, 6,
            1, 6, 2,
            2, 6, 7,
            2, 7, 3,
            3, 7, 4,
            3, 4, 0,
            4, 7, 6,
            4, 6, 5,
            3, 0, 1,
            3, 1, 2,
    };

    //
    float[] colors = {
            1f, 0f, 0f, 1f, // vertex 0 red
            0f, 1f, 0f, 1f, // vertex 1 green
            0f, 0f, 1f, 1f, // vertex 2 blue
            1f, 1f, 0f, 1f, // vertex 3
            0f, 1f, 1f, 1f, // vertex 4
            1f, 0f, 1f, 1f, // vertex 5
            0f, 0f, 0f, 1f, // vertex 6
            1f, 1f, 1f, 1f, // vertex 7
    };

    float[] colorsBlack = {
            0f, 0f, 0f, 1f, // vertex 0 red
            0f, 0f, 0f, 1f, // vertex 1 green
            0f, 0f, 0f, 1f, // vertex 2 blue
            0f, 0f, 0f, 1f, // vertex 3
            0f, 0f, 0f, 1f, // vertex 4
            0f, 0f, 0f, 1f, // vertex 5
            0f, 0f, 0f, 1f, // vertex 6
            0f, 0f, 0f, 1f, // vertex 7
    };


    private final int SCALE = 10000;

    public Cube(float width, float height, float depth) {

        // 地图坐标系比较大，将值放大以免太小看不见
        width *= SCALE;
        height *= SCALE;
        depth *= SCALE;


        width /= 2;
        height /= 2;
        depth /= 1;

        //尽量不要让z轴有负数出现
        float vertices1[] = {
                -width, -height, -0,
                width, -height, -0,
                width, height, -0,
                -width, height, -0,
                -width, -height, depth,
                width, -height, depth,
                width, height, depth,
                -width, height, depth,
        };

        for (int i = 0; i < vertices1.length; i++) {
            verticesList.add(vertices1[i]);
        }

        //index
        ByteBuffer byteBuffer = ByteBuffer.allocateDirect(indices.length * 4);
        byteBuffer.order(ByteOrder.nativeOrder());
        indexBuffer = byteBuffer.asShortBuffer();
        indexBuffer.put(indices);
        indexBuffer.position(0);


        //color
        ByteBuffer byteBuffer1 = ByteBuffer.allocateDirect(colors.length * 4);
        byteBuffer1.order(ByteOrder.nativeOrder());
        colorBuffer = byteBuffer1.asFloatBuffer();
        colorBuffer.put(colors);
        colorBuffer.position(0);


        byteBuffer1 = ByteBuffer.allocateDirect(colorsBlack.length * 4);
        byteBuffer1.order(ByteOrder.nativeOrder());
        colorBlcakBuffer = byteBuffer1.asFloatBuffer();
        colorBlcakBuffer.put(colorsBlack);
        colorBlcakBuffer.position(0);

        init();

    }


    private FloatBuffer vertextBuffer;
    private ShortBuffer indexBuffer;
    private FloatBuffer colorBuffer;
    private FloatBuffer colorBlcakBuffer;

    private void init() {
        if (vertextBuffer == null) {
            ByteBuffer byteBuffer = ByteBuffer.allocateDirect(verticesList.size() * 4);
            byteBuffer.order(ByteOrder.nativeOrder());
            vertextBuffer = byteBuffer.asFloatBuffer();
        }
        vertextBuffer.clear();
        for (Float f : verticesList) {
            vertextBuffer.put(f);
        }
        vertextBuffer.position(0);
    }


    class MyShader {
        String vertexShader = "precision highp float;\n" +
                "        attribute vec3 aVertex;//顶点数组,三维坐标\n" +
                "        attribute vec4 aColor;//颜色数组,三维坐标\n" +
                "        uniform mat4 aMVPMatrix;//mvp矩阵\n" +
                "        varying vec4 color;//\n" +
                "        void main(){\n" +
                "            gl_Position = aMVPMatrix * vec4(aVertex, 1.0);\n" +
                "            color = aColor;\n" +
                "        }";

        String fragmentShader = "//有颜色 没有纹理\n" +
                "        precision highp float;\n" +
                "        varying vec4 color;//\n" +
                "        void main(){\n" +
                "            gl_FragColor = color;\n" +
                "        }";

        int aVertex,aMVPMatrix,aColor;
        int program;

        public void create() {
            int vertexLocation = GLES20.glCreateShader(GLES20.GL_VERTEX_SHADER);
            int fragmentLocation = GLES20.glCreateShader(GLES20.GL_FRAGMENT_SHADER);

            GLES20.glShaderSource(vertexLocation,vertexShader);
            GLES20.glCompileShader(vertexLocation);

            GLES20.glShaderSource(fragmentLocation,fragmentShader);
            GLES20.glCompileShader(fragmentLocation);

            program = GLES20.glCreateProgram();
            GLES20.glAttachShader(program,vertexLocation);
            GLES20.glAttachShader(program,fragmentLocation);
            GLES20.glLinkProgram(program);


            aVertex  = GLES20.glGetAttribLocation(program, "aVertex");
            aMVPMatrix = GLES20.glGetUniformLocation(program,"aMVPMatrix");
            aColor = GLES20.glGetAttribLocation(program,"aColor");

        }
    }

    MyShader shader;

    public void initShader() {
        shader = new MyShader();
        shader.create();
    }



    public void drawES20(float[] mvp) {
        display(mvp, colorBuffer, true);
    }

    private void display(float[] mvp, FloatBuffer color, boolean depthMask) {

        GLES20.glUseProgram(shader.program);

        GLES20.glEnable(GLES20.GL_DEPTH_TEST);
        GLES20.glDepthMask(depthMask);
        GLES20.glEnableVertexAttribArray(shader.aVertex);

        //顶点指针
        GLES20.glVertexAttribPointer(shader.aVertex, 3, GLES20.GL_FLOAT, false, 0, vertextBuffer);

        //颜色指针
        GLES20.glEnableVertexAttribArray(shader.aColor);
        GLES20.glVertexAttribPointer(shader.aColor,4, GLES20.GL_FLOAT,false,0,color);

        GLES20.glUniformMatrix4fv(shader.aMVPMatrix,1,false,mvp,0);

        //开始画
        GLES20.glDrawElements(GLES20.GL_TRIANGLES, indices.length, GLES20.GL_UNSIGNED_SHORT, indexBuffer);
        GLES20.glDisableVertexAttribArray(shader.aVertex);

        GLES20.glDisable(GLES20.GL_DEPTH_TEST);

    }

    float[] shadowMtx = {
            1,0,0,0,
            0,1,0,0,
            0,0,1,0,
            0,0,0,1
    };
    float[] ground = { 0.0f, 0.0f, 1.0f, -0.1f };
    float[] lightPos = {SCALE * 1.F, SCALE * 1.F, SCALE * 1.F , 1.0F};

    public void drawShadow(float[] mvp) {
        changeLightPos();

        mtxShadow(shadowMtx, ground,lightPos);
//        mtxReflected(shadowMtx, ground,lightPos);
        Matrix.multiplyMM(shadowMtx, 0, mvp,0 ,shadowMtx , 0);

        display(shadowMtx, colorBlcakBuffer, false);

    }

    float rotate = 0;
    final float LIGHT_RADIUS = 2;

    private void changeLightPos() {
        lightPos[0] = (float) (Math.cos(rotate * Math.PI / 180.F) * SCALE * LIGHT_RADIUS);
        lightPos[1] = (float) (Math.sin(rotate  * Math.PI / 180.F) * SCALE * LIGHT_RADIUS);
        rotate ++;
        rotate = rotate % 360;
    }

    private void mtxShadow(float[] _result, float[] _ground, float[] _light)
    {
	    float dot =
            _ground[0] * _light[0]
                    + _ground[1] * _light[1]
                    + _ground[2] * _light[2]
                    + _ground[3] * _light[3]
            ;

        _result[ 0] =  dot - _light[0] * _ground[0];
        _result[ 1] = 0.0f - _light[1] * _ground[0];
        _result[ 2] = 0.0f - _light[2] * _ground[0];
        _result[ 3] = 0.0f - _light[3] * _ground[0];

        _result[ 4] = 0.0f - _light[0] * _ground[1];
        _result[ 5] =  dot - _light[1] * _ground[1];
        _result[ 6] = 0.0f - _light[2] * _ground[1];
        _result[ 7] = 0.0f - _light[3] * _ground[1];

        _result[ 8] = 0.0f - _light[0] * _ground[2];
        _result[ 9] = 0.0f - _light[1] * _ground[2];
        _result[10] =  dot - _light[2] * _ground[2];
        _result[11] = 0.0f - _light[3] * _ground[2];

        _result[12] = 0.0f - _light[0] * _ground[3];
        _result[13] = 0.0f - _light[1] * _ground[3];
        _result[14] = 0.0f - _light[2] * _ground[3];
        _result[15] =  dot - _light[3] * _ground[3];
    }


    void mtxReflected(float[] _result, float[] _pos, float[] _normal)
    {
	    float nx = _normal[0];
	    float ny = _normal[1];
	    float nz = _normal[2];

        _result[ 0] =  1.0f - 2.0f * nx * nx;
        _result[ 1] =       - 2.0f * nx * ny;
        _result[ 2] =       - 2.0f * nx * nz;
        _result[ 3] =  0.0f;

        _result[ 4] =       - 2.0f * nx * ny;
        _result[ 5] =  1.0f - 2.0f * ny * ny;
        _result[ 6] =       - 2.0f * ny * nz;
        _result[ 7] =  0.0f;

        _result[ 8] =       - 2.0f * nx * nz;
        _result[ 9] =       - 2.0f * ny * nz;
        _result[10] =  1.0f - 2.0f * nz * nz;
        _result[11] =  0.0f;

	    float dot = dot(_pos, _normal);

        _result[12] =  2.0f * dot * nx;
        _result[13] =  2.0f * dot * ny;
        _result[14] =  2.0f * dot * nz;
        _result[15] =  1.0f;
    }

    private float dot(float[] pos, float[] normal) {
        if (pos.length != normal.length) {
            return 0;
        }
        float result = 0;
        for (int i = 0; i < pos.length; i++) {
            result += pos[i] * normal[i];
        }
        return result;
    }


}
