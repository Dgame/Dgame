module Dgame.Graphic.Blend;

import derelict.opengl3.gl;

struct Blend {
    static immutable Blend One     = Blend(Factor.One, Factor.One);
    static immutable Blend Zero    = Blend(Factor.Zero, Factor.Zero);
    static immutable Blend Default = Blend(Factor.SrcAlpha, Factor.OneMinusSrcAlpha);

    enum Factor {
        Zero = GL_ZERO,
        One = GL_ONE,
        SrcColor = GL_SRC_COLOR,
        OneMinusSrcColor = GL_ONE_MINUS_SRC_COLOR,
        DstColor = GL_DST_COLOR,
        OneMinusDstColor = GL_ONE_MINUS_DST_COLOR,
        SrcAlpha = GL_SRC_ALPHA,
        OneMinusSrcAlpha = GL_ONE_MINUS_SRC_ALPHA,
        DstAlpha = GL_DST_ALPHA,
        OneMinusDstAlpha = GL_ONE_MINUS_DST_ALPHA
    }

    Factor srcColor = Factor.One;
    Factor dstColor = Factor.Zero;

    @nogc
    void use() const nothrow {
        glBlendFunc(this.srcColor, this.dstColor);
    }
}