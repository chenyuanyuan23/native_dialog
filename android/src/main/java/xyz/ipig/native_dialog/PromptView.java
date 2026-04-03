package xyz.ipig.native_dialog;

import android.animation.ObjectAnimator;
import android.animation.ValueAnimator;
import android.annotation.SuppressLint;
import android.text.StaticLayout;
import android.text.Layout;
import android.app.Activity;
import android.content.Context;
import android.graphics.Bitmap;
import android.graphics.BitmapFactory;
import android.graphics.Canvas;
import android.graphics.Color;
import android.graphics.Matrix;
import android.graphics.Paint;
import android.text.TextPaint;
import android.graphics.PixelFormat;
import android.graphics.PorterDuff;
import android.graphics.PorterDuffXfermode;
import android.graphics.Rect;
import android.graphics.RectF;
import android.graphics.drawable.AnimationDrawable;
import android.graphics.drawable.BitmapDrawable;
import android.graphics.drawable.Drawable;
import android.graphics.drawable.ShapeDrawable;
import android.graphics.drawable.shapes.RoundRectShape;
// import android.support.annotation.NonNull;
import android.util.AttributeSet;
import android.util.Log;
import android.view.MotionEvent;
import android.view.animation.Animation;
import android.view.animation.LinearInterpolator;
import android.widget.ImageView;

/**
 * Created by limxing on 16/1/7.
 * https://www.github.com/limxing
 */
@SuppressLint("AppCompatCustomView")
class PromptView extends ImageView {
    public static final int PROMPT_SUCCESS = 101;
    public static final int PROMPT_LOADING = 102;
    public static final int PROMPT_ERROR = 103;
    public static final int PROMPT_NONE = 104;
    public static final int PROMPT_INFO = 105;
    public static final int PROMPT_WARN = 106;
    public static final int PROMPT_ALERT_WARN = 107;
    private static final String TAG = "LOADVIEW";
    public static final int PROMPT_CUSTOM = 108;
    public static final int PROMPT_AD = 109;
    public static final int CUSTOMER_LOADING = 110;
    private PromptDialog promptDialog;
    private Builder builder;
    private int width;
    private int height;
    private ValueAnimator animator;
    private Paint paint;
    private TextPaint tpaint;
    private float density;
    private Rect textRect;
    private int canvasWidth;
    private int canvasHeight;
    private RectF roundRect;
    private int currentType;//当前窗口类型
    private PromptButton[] buttons = new PromptButton[]{};
    private RectF roundTouchRect;
    float buttonW;
    float buttonH;
    private boolean isSheet;
    private float bottomHeight;
    private float sheetHeight;
    private Drawable drawableClose;
    private int transX;
    private int transY;
    private Bitmap adBitmap;

//    private static final int sheetCellHeight = 54;
//    private static final int sheetCellPad = 13;
//    private final int pressAlph = 15;


    public PromptView(Context context) {
        super(context);
    }

    public PromptView(Context context, AttributeSet attrs) {
        super(context, attrs);
    }

    public PromptView(Context context, AttributeSet attrs, int defStyleAttr) {
        super(context, attrs, defStyleAttr);
    }

    public PromptView(Activity context, Builder builder, PromptDialog promptDialog) {
        super(context);
        density = getResources().getDisplayMetrics().density;

        this.builder = builder;
        this.promptDialog = promptDialog;

    }



    @Override
    protected void onDraw(Canvas canvas) {
        if (paint == null) return;
        if (canvasWidth == 0) {
            canvasWidth = getWidth();
            canvasHeight = getHeight();
        }
        int bgColor = Color.BLACK;
        int bgAlpha = 180;
        int textColor = Color.WHITE;

        paint.reset();
        paint.setAntiAlias(true);
        paint.setColor(builder.backColor);
        paint.setAlpha(builder.backAlpha);
        canvas.drawRect(0, 0, canvasWidth, canvasHeight, paint);
        
        String [] temp = builder.text.split("-");

        String text = temp[1];
        float pad = builder.padding * density;
        float round = builder.round * density;
        paint.reset();
        paint.setColor(textColor);
        paint.setStrokeWidth(1 * density);
        paint.setTextSize(density * builder.textSize);
        paint.setAntiAlias(true);
        paint.getTextBounds(text, 0, text.length(), textRect);
//        paint.getTextBounds(text, 0, text.length(), textRect);
        float popWidth = 0;
        float popHeight = 0;


        popWidth = Math.max(100 * density, textRect.width() + pad * 2);
        popHeight = textRect.height() + 3 * pad + height * 2;



        float transTop = canvasHeight / 2 - popHeight / 2;
        float transLeft = canvasWidth / 2 - popWidth / 2;

        canvas.translate(transLeft, transTop);
        // canvas.translate(transLeft, transTop);

        paint.reset();
        paint.setAntiAlias(true);
//        paint.setColor(builder.roundColor);
        // paint.setAlpha(builder.roundAlpha);
        paint.setColor(bgColor); // 设置圆角矩形背景颜色为黑色
        paint.setAlpha(bgAlpha); // 设置圆角矩形背景的透明度为50%
        if (roundTouchRect == null)
            roundTouchRect = new RectF();
        roundTouchRect.set(transLeft, transTop, transLeft + popWidth, transTop + popHeight);
        if (roundRect == null)
            roundRect = new RectF(0, 0, popWidth, popHeight);
        roundRect.set(0, 0, popWidth, popHeight);
        canvas.drawRoundRect(roundRect, round, round, paint);
        

        paint.reset();
        paint.setColor(textColor);
        paint.setStrokeWidth(1 * density);
        paint.setTextSize(density * builder.textSize);
        paint.setAntiAlias(true);
        paint.setTextAlign(Paint.Align.CENTER);

        float top1 = pad * 2 + height * 2 + textRect.height() - 38;
        canvas.drawText(temp[0], popWidth / 2, top1, paint);

        paint.reset();
        paint.setColor(textColor);
        paint.setStrokeWidth(1 * density);
        paint.setTextSize(density * builder.textSize);
        paint.setAntiAlias(true);

        float top = pad * 2 + height * 2 + textRect.height() - 35;
        canvas.drawText(temp[1], popWidth / 2, top + 50, paint);
        canvas.translate(popWidth / 2 - width, pad);

        
        // canvas.translate(popWidth / 2 - width, pad);

        super.onDraw(canvas);
    }

    private float getFontHeight(TextPaint paint) {
    Paint.FontMetrics fm = paint.getFontMetrics();// 得到系统默认字体属性
    return fm.bottom - fm.top;
}

    @Override
    protected void onAttachedToWindow() {
        super.onAttachedToWindow();
        setScaleType(ScaleType.MATRIX);

        if (tpaint == null){
            tpaint = new TextPaint();
            paint = new Paint();
        }
        initData();
    }

    private void initData() {
        if (textRect == null)
            textRect = new Rect();
        if (roundRect == null)
            roundTouchRect = new RectF();

        buttonW = density * 120;
        buttonH = density * 44;
    }

    @Override
    protected void onDetachedFromWindow() {
        super.onDetachedFromWindow();

        if (adBitmap != null) {
            adBitmap.recycle();
        }
        adBitmap = null;

        if (animator != null)
            animator.cancel();
        animator = null;
        buttons = null;
//        textRect = null;
//        roundTouchRect = null;
        promptDialog.onDetach();
//        promptDialog = null;
        currentType = PROMPT_NONE;

    }


    private Matrix max;

    /**
     * loading start
     */
    private void start() {
        if (max == null || animator == null) {
            max = new Matrix();
            animator = ValueAnimator.ofInt(0, 12);
            animator.setDuration(12 * 80);
            animator.setInterpolator(new LinearInterpolator());
            animator.setRepeatCount(Animation.INFINITE);
            animator.addUpdateListener(new ValueAnimator.AnimatorUpdateListener() {
                @Override
                public void onAnimationUpdate(ValueAnimator valueAnimator) {
                    float degrees = 30 * (Integer) valueAnimator.getAnimatedValue();
                    max.setRotate(degrees, width, height);
                    setImageMatrix(max);
                }
            });
        }
        if (!animator.isRunning())
            animator.start();
    }




    /**
     * 停止旋转
     */

    private void endAnimator() {
        if (animator != null && animator.isRunning()) {
            animator.end();
        }
    }

    /**
     *
     */
    public void showLoading() {
        if (currentType == PROMPT_ALERT_WARN) {
            isSheet = buttons.length > 2;
        } else {
            isSheet = false;
        }
        setImageDrawable(getResources().getDrawable(builder.icon));
        width = getDrawable().getMinimumWidth() / 2;
        height = getDrawable().getMinimumHeight() / 2;
        System.out.println(width);
        System.out.println(height);
        start();
        currentType = PROMPT_LOADING;

    }

    Builder getBuilder() {
        return builder;
    }

    public void showSomthing(int currentType) {
        this.currentType = currentType;
        if (currentType == PROMPT_ALERT_WARN) {
            isSheet = buttons.length > 2;
        } else {
            isSheet = false;
        }
        endAnimator();
        setImageDrawable(getResources().getDrawable(builder.icon));
        width = getDrawable().getMinimumWidth() / 2;
        height = getDrawable().getMinimumHeight() / 2;

        if (max != null) {
            max.setRotate(0, width, height);
            setImageMatrix(max);
        }

        if (isSheet) {
            //计算高度
            sheetHeight = (1.5f * builder.sheetCellPad + builder.sheetCellHeight * buttons.length) * density;
            Log.i(TAG, "showSomthing: " + sheetHeight);
            startBottomToTopAnim();
        }
        invalidate();
    }

    /**
     * 底部Sheet
     */
    private void startBottomToTopAnim() {
        ValueAnimator bottomToTopAnim = ObjectAnimator.ofFloat(0, 1);
//        bottomToTopAnim.setStartDelay(100);
        bottomToTopAnim.setDuration(300);
        bottomToTopAnim.addUpdateListener(new ValueAnimator.AnimatorUpdateListener() {
            @Override
            public void onAnimationUpdate(ValueAnimator valueAnimator) {
                Float value = (Float) valueAnimator.getAnimatedValue();
                bottomHeight = sheetHeight * value;
                Log.i(TAG, "onAnimationUpdate: " + bottomHeight);
                invalidate();
            }
        });
        bottomToTopAnim.start();
    }


    void showSomthingAlert(PromptButton... button) {
        this.buttons = button;
        showSomthing(PROMPT_ALERT_WARN);

    }

    public void setBuilder(Builder builder) {
        if (this.builder != builder)
            this.builder = builder;
    }

    public int getCurrentType() {
        return currentType;
    }

    public void setText(String msg) {
        builder.text(msg);
        invalidate();
    }

    /**
     * 底部Sheet 退出动画
     */
    public void dismiss() {
//        currentType = PROMPT_NONE;
        if (isSheet) {

            ValueAnimator bottomToTopAnim = ObjectAnimator.ofFloat(1, 0);
            bottomToTopAnim.setDuration(300);
            bottomToTopAnim.addUpdateListener(new ValueAnimator.AnimatorUpdateListener() {
                @Override
                public void onAnimationUpdate(ValueAnimator valueAnimator) {
                    Float value = (Float) valueAnimator.getAnimatedValue();
                    bottomHeight = sheetHeight * value;
                    invalidate();
                }
            });
            bottomToTopAnim.start();
        }

    }

    public void showAd() {
        this.currentType = PROMPT_AD;
        endAnimator();
    }

    /**
     * 展示自定义的loading
     */
    public void showCustomLoading() {
        if (currentType == PROMPT_ALERT_WARN) {
            isSheet = buttons.length > 2;
        } else {
            isSheet = false;
        }
        setImageDrawable(getResources().getDrawable(builder.icon));
        width = getDrawable().getMinimumWidth() / 2;
        height = getDrawable().getMinimumHeight() / 2;
        AnimationDrawable animationDrawable = (AnimationDrawable) getDrawable();
        animationDrawable.start();
        currentType = CUSTOMER_LOADING;
    }

    /**
     * 停止自定义的loading
     */
    public void stopCustomerLoading() {
        AnimationDrawable animationDrawable = (AnimationDrawable) getDrawable();
        animationDrawable.stop();
    }
}