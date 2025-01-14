��
l��F� j�P.�M�.�}q (X   protocol_versionqM�X   little_endianq�X
   type_sizesq}q(X   shortqKX   intqKX   longqKuu.�(X   moduleq cmodels.shapes_cnn
ShapesCNN
qXg   D:\OneDrive\Learning\University\Masters-UvA\Project AI\diagnostics-shapes\baseline\models\shapes_cnn.pyqX{  class ShapesCNN(nn.Module):
    def __init__(self, n_out_features):
        super().__init__()

        n_filters = 20

        self.conv_net = nn.Sequential(
            nn.Conv2d(3, n_filters, 3, stride=2),
            nn.BatchNorm2d(n_filters),
            nn.ReLU(),
            nn.Conv2d(n_filters, n_filters, 3, stride=2),
            nn.BatchNorm2d(n_filters),
            nn.ReLU(),
            nn.Conv2d(n_filters, n_filters, 3, stride=2),
            nn.BatchNorm2d(n_filters),
            nn.ReLU()
        )
        self.lin = nn.Sequential(nn.Linear(80, n_out_features), nn.ReLU())

        self._init_params()

    def _init_params(self):
        for m in self.modules():
            if isinstance(m, nn.Conv2d):
                nn.init.kaiming_normal_(m.weight, mode="fan_out", nonlinearity="relu")
            elif isinstance(m, nn.BatchNorm2d):
                nn.init.constant_(m.weight, 1)
                nn.init.constant_(m.bias, 0)

    def forward(self, x):
        batch_size = x.size(0)
        output = self.conv_net(x)
        output = output.view(batch_size, -1)
        output = self.lin(output)
        return output
qtqQ)�q}q(X   _backendqctorch.nn.backends.thnn
_get_thnn_function_backend
q)Rq	X   _parametersq
ccollections
OrderedDict
q)RqX   _buffersqh)RqX   _backward_hooksqh)RqX   _forward_hooksqh)RqX   _forward_pre_hooksqh)RqX   _state_dict_hooksqh)RqX   _load_state_dict_pre_hooksqh)RqX   _modulesqh)Rq(X   conv_netq(h ctorch.nn.modules.container
Sequential
qXQ   C:\Users\kztod\Anaconda3\envs\cee\lib\site-packages\torch\nn\modules\container.pyqX�	  class Sequential(Module):
    r"""A sequential container.
    Modules will be added to it in the order they are passed in the constructor.
    Alternatively, an ordered dict of modules can also be passed in.

    To make it easier to understand, here is a small example::

        # Example of using Sequential
        model = nn.Sequential(
                  nn.Conv2d(1,20,5),
                  nn.ReLU(),
                  nn.Conv2d(20,64,5),
                  nn.ReLU()
                )

        # Example of using Sequential with OrderedDict
        model = nn.Sequential(OrderedDict([
                  ('conv1', nn.Conv2d(1,20,5)),
                  ('relu1', nn.ReLU()),
                  ('conv2', nn.Conv2d(20,64,5)),
                  ('relu2', nn.ReLU())
                ]))
    """

    def __init__(self, *args):
        super(Sequential, self).__init__()
        if len(args) == 1 and isinstance(args[0], OrderedDict):
            for key, module in args[0].items():
                self.add_module(key, module)
        else:
            for idx, module in enumerate(args):
                self.add_module(str(idx), module)

    def _get_item_by_idx(self, iterator, idx):
        """Get the idx-th item of the iterator"""
        size = len(self)
        idx = operator.index(idx)
        if not -size <= idx < size:
            raise IndexError('index {} is out of range'.format(idx))
        idx %= size
        return next(islice(iterator, idx, None))

    def __getitem__(self, idx):
        if isinstance(idx, slice):
            return self.__class__(OrderedDict(list(self._modules.items())[idx]))
        else:
            return self._get_item_by_idx(self._modules.values(), idx)

    def __setitem__(self, idx, module):
        key = self._get_item_by_idx(self._modules.keys(), idx)
        return setattr(self, key, module)

    def __delitem__(self, idx):
        if isinstance(idx, slice):
            for key in list(self._modules.keys())[idx]:
                delattr(self, key)
        else:
            key = self._get_item_by_idx(self._modules.keys(), idx)
            delattr(self, key)

    def __len__(self):
        return len(self._modules)

    def __dir__(self):
        keys = super(Sequential, self).__dir__()
        keys = [key for key in keys if not key.isdigit()]
        return keys

    def forward(self, input):
        for module in self._modules.values():
            input = module(input)
        return input
qtqQ)�q }q!(hh	h
h)Rq"hh)Rq#hh)Rq$hh)Rq%hh)Rq&hh)Rq'hh)Rq(hh)Rq)(X   0q*(h ctorch.nn.modules.conv
Conv2d
q+XL   C:\Users\kztod\Anaconda3\envs\cee\lib\site-packages\torch\nn\modules\conv.pyq,X!  class Conv2d(_ConvNd):
    r"""Applies a 2D convolution over an input signal composed of several input
    planes.

    In the simplest case, the output value of the layer with input size
    :math:`(N, C_{\text{in}}, H, W)` and output :math:`(N, C_{\text{out}}, H_{\text{out}}, W_{\text{out}})`
    can be precisely described as:

    .. math::
        \text{out}(N_i, C_{\text{out}_j}) = \text{bias}(C_{\text{out}_j}) +
        \sum_{k = 0}^{C_{\text{in}} - 1} \text{weight}(C_{\text{out}_j}, k) \star \text{input}(N_i, k)


    where :math:`\star` is the valid 2D `cross-correlation`_ operator,
    :math:`N` is a batch size, :math:`C` denotes a number of channels,
    :math:`H` is a height of input planes in pixels, and :math:`W` is
    width in pixels.

    * :attr:`stride` controls the stride for the cross-correlation, a single
      number or a tuple.

    * :attr:`padding` controls the amount of implicit zero-paddings on both
      sides for :attr:`padding` number of points for each dimension.

    * :attr:`dilation` controls the spacing between the kernel points; also
      known as the à trous algorithm. It is harder to describe, but this `link`_
      has a nice visualization of what :attr:`dilation` does.

    * :attr:`groups` controls the connections between inputs and outputs.
      :attr:`in_channels` and :attr:`out_channels` must both be divisible by
      :attr:`groups`. For example,

        * At groups=1, all inputs are convolved to all outputs.
        * At groups=2, the operation becomes equivalent to having two conv
          layers side by side, each seeing half the input channels,
          and producing half the output channels, and both subsequently
          concatenated.
        * At groups= :attr:`in_channels`, each input channel is convolved with
          its own set of filters, of size:
          :math:`\left\lfloor\frac{C_\text{out}}{C_\text{in}}\right\rfloor`.

    The parameters :attr:`kernel_size`, :attr:`stride`, :attr:`padding`, :attr:`dilation` can either be:

        - a single ``int`` -- in which case the same value is used for the height and width dimension
        - a ``tuple`` of two ints -- in which case, the first `int` is used for the height dimension,
          and the second `int` for the width dimension

    .. note::

         Depending of the size of your kernel, several (of the last)
         columns of the input might be lost, because it is a valid `cross-correlation`_,
         and not a full `cross-correlation`_.
         It is up to the user to add proper padding.

    .. note::

        When `groups == in_channels` and `out_channels == K * in_channels`,
        where `K` is a positive integer, this operation is also termed in
        literature as depthwise convolution.

        In other words, for an input of size :math:`(N, C_{in}, H_{in}, W_{in})`,
        a depthwise convolution with a depthwise multiplier `K`, can be constructed by arguments
        :math:`(in\_channels=C_{in}, out\_channels=C_{in} \times K, ..., groups=C_{in})`.

    .. include:: cudnn_deterministic.rst

    Args:
        in_channels (int): Number of channels in the input image
        out_channels (int): Number of channels produced by the convolution
        kernel_size (int or tuple): Size of the convolving kernel
        stride (int or tuple, optional): Stride of the convolution. Default: 1
        padding (int or tuple, optional): Zero-padding added to both sides of the input. Default: 0
        dilation (int or tuple, optional): Spacing between kernel elements. Default: 1
        groups (int, optional): Number of blocked connections from input channels to output channels. Default: 1
        bias (bool, optional): If ``True``, adds a learnable bias to the output. Default: ``True``

    Shape:
        - Input: :math:`(N, C_{in}, H_{in}, W_{in})`
        - Output: :math:`(N, C_{out}, H_{out}, W_{out})` where

          .. math::
              H_{out} = \left\lfloor\frac{H_{in}  + 2 \times \text{padding}[0] - \text{dilation}[0]
                        \times (\text{kernel\_size}[0] - 1) - 1}{\text{stride}[0]} + 1\right\rfloor

          .. math::
              W_{out} = \left\lfloor\frac{W_{in}  + 2 \times \text{padding}[1] - \text{dilation}[1]
                        \times (\text{kernel\_size}[1] - 1) - 1}{\text{stride}[1]} + 1\right\rfloor

    Attributes:
        weight (Tensor): the learnable weights of the module of shape
                         (out_channels, in_channels, kernel_size[0], kernel_size[1]).
                         The values of these weights are sampled from
                         :math:`\mathcal{U}(-\sqrt{k}, \sqrt{k})` where
                         :math:`k = \frac{1}{C_\text{in} * \prod_{i=0}^{1}\text{kernel\_size}[i]}`
        bias (Tensor):   the learnable bias of the module of shape (out_channels). If :attr:`bias` is ``True``,
                         then the values of these weights are
                         sampled from :math:`\mathcal{U}(-\sqrt{k}, \sqrt{k})` where
                         :math:`k = \frac{1}{C_\text{in} * \prod_{i=0}^{1}\text{kernel\_size}[i]}`

    Examples::

        >>> # With square kernels and equal stride
        >>> m = nn.Conv2d(16, 33, 3, stride=2)
        >>> # non-square kernels and unequal stride and with padding
        >>> m = nn.Conv2d(16, 33, (3, 5), stride=(2, 1), padding=(4, 2))
        >>> # non-square kernels and unequal stride and with padding and dilation
        >>> m = nn.Conv2d(16, 33, (3, 5), stride=(2, 1), padding=(4, 2), dilation=(3, 1))
        >>> input = torch.randn(20, 16, 50, 100)
        >>> output = m(input)

    .. _cross-correlation:
        https://en.wikipedia.org/wiki/Cross-correlation

    .. _link:
        https://github.com/vdumoulin/conv_arithmetic/blob/master/README.md
    """
    def __init__(self, in_channels, out_channels, kernel_size, stride=1,
                 padding=0, dilation=1, groups=1, bias=True):
        kernel_size = _pair(kernel_size)
        stride = _pair(stride)
        padding = _pair(padding)
        dilation = _pair(dilation)
        super(Conv2d, self).__init__(
            in_channels, out_channels, kernel_size, stride, padding, dilation,
            False, _pair(0), groups, bias)

    @weak_script_method
    def forward(self, input):
        return F.conv2d(input, self.weight, self.bias, self.stride,
                        self.padding, self.dilation, self.groups)
q-tq.Q)�q/}q0(hh	h
h)Rq1(X   weightq2ctorch._utils
_rebuild_parameter
q3ctorch._utils
_rebuild_tensor_v2
q4((X   storageq5ctorch
FloatStorage
q6X   2508476265632q7X   cpuq8MNtq9QK (KKKKtq:(KK	KKtq;�h)Rq<tq=Rq>�h)Rq?�q@RqAX   biasqBh3h4((h5h6X   2508476261120qCh8KNtqDQK K�qEK�qF�h)RqGtqHRqI�h)RqJ�qKRqLuhh)RqMhh)RqNhh)RqOhh)RqPhh)RqQhh)RqRhh)RqSX   trainingqT�X   in_channelsqUKX   out_channelsqVKX   kernel_sizeqWKK�qXX   strideqYKK�qZX   paddingq[K K �q\X   dilationq]KK�q^X
   transposedq_�X   output_paddingq`K K �qaX   groupsqbKubX   1qc(h ctorch.nn.modules.batchnorm
BatchNorm2d
qdXQ   C:\Users\kztod\Anaconda3\envs\cee\lib\site-packages\torch\nn\modules\batchnorm.pyqeX#  class BatchNorm2d(_BatchNorm):
    r"""Applies Batch Normalization over a 4D input (a mini-batch of 2D inputs
    with additional channel dimension) as described in the paper
    `Batch Normalization: Accelerating Deep Network Training by Reducing Internal Covariate Shift`_ .

    .. math::

        y = \frac{x - \mathrm{E}[x]}{ \sqrt{\mathrm{Var}[x] + \epsilon}} * \gamma + \beta

    The mean and standard-deviation are calculated per-dimension over
    the mini-batches and :math:`\gamma` and :math:`\beta` are learnable parameter vectors
    of size `C` (where `C` is the input size). By default, the elements of :math:`\gamma` are sampled
    from :math:`\mathcal{U}(0, 1)` and the elements of :math:`\beta` are set to 0.

    Also by default, during training this layer keeps running estimates of its
    computed mean and variance, which are then used for normalization during
    evaluation. The running estimates are kept with a default :attr:`momentum`
    of 0.1.

    If :attr:`track_running_stats` is set to ``False``, this layer then does not
    keep running estimates, and batch statistics are instead used during
    evaluation time as well.

    .. note::
        This :attr:`momentum` argument is different from one used in optimizer
        classes and the conventional notion of momentum. Mathematically, the
        update rule for running statistics here is
        :math:`\hat{x}_\text{new} = (1 - \text{momentum}) \times \hat{x} + \text{momemtum} \times x_t`,
        where :math:`\hat{x}` is the estimated statistic and :math:`x_t` is the
        new observed value.

    Because the Batch Normalization is done over the `C` dimension, computing statistics
    on `(N, H, W)` slices, it's common terminology to call this Spatial Batch Normalization.

    Args:
        num_features: :math:`C` from an expected input of size
            :math:`(N, C, H, W)`
        eps: a value added to the denominator for numerical stability.
            Default: 1e-5
        momentum: the value used for the running_mean and running_var
            computation. Can be set to ``None`` for cumulative moving average
            (i.e. simple average). Default: 0.1
        affine: a boolean value that when set to ``True``, this module has
            learnable affine parameters. Default: ``True``
        track_running_stats: a boolean value that when set to ``True``, this
            module tracks the running mean and variance, and when set to ``False``,
            this module does not track such statistics and always uses batch
            statistics in both training and eval modes. Default: ``True``

    Shape:
        - Input: :math:`(N, C, H, W)`
        - Output: :math:`(N, C, H, W)` (same shape as input)

    Examples::

        >>> # With Learnable Parameters
        >>> m = nn.BatchNorm2d(100)
        >>> # Without Learnable Parameters
        >>> m = nn.BatchNorm2d(100, affine=False)
        >>> input = torch.randn(20, 100, 35, 45)
        >>> output = m(input)

    .. _`Batch Normalization: Accelerating Deep Network Training by Reducing Internal Covariate Shift`:
        https://arxiv.org/abs/1502.03167
    """

    @weak_script_method
    def _check_input_dim(self, input):
        if input.dim() != 4:
            raise ValueError('expected 4D input (got {}D input)'
                             .format(input.dim()))
qftqgQ)�qh}qi(hh	h
h)Rqj(h2h3h4((h5h6X   2508476261792qkh8KNtqlQK K�qmK�qn�h)RqotqpRqq�h)Rqr�qsRqthBh3h4((h5h6X   2508476264288quh8KNtqvQK K�qwK�qx�h)RqytqzRq{�h)Rq|�q}Rq~uhh)Rq(X   running_meanq�h4((h5h6X   2508476263232q�h8KNtq�QK K�q�K�q��h)Rq�tq�Rq�X   running_varq�h4((h5h6X   2508476263328q�h8KNtq�QK K�q�K�q��h)Rq�tq�Rq�X   num_batches_trackedq�h4((h5ctorch
LongStorage
q�X   2508476263712q�h8KNtq�QK ))�h)Rq�tq�Rq�uhh)Rq�hh)Rq�hh)Rq�hh)Rq�hh)Rq�hh)Rq�hT�X   num_featuresq�KX   epsq�G>�����h�X   momentumq�G?�������X   affineq��X   track_running_statsq��ubX   2q�(h ctorch.nn.modules.activation
ReLU
q�XR   C:\Users\kztod\Anaconda3\envs\cee\lib\site-packages\torch\nn\modules\activation.pyq�X�  class ReLU(Threshold):
    r"""Applies the rectified linear unit function element-wise
    :math:`\text{ReLU}(x)= \max(0, x)`

    .. image:: scripts/activation_images/ReLU.png

    Args:
        inplace: can optionally do the operation in-place. Default: ``False``

    Shape:
        - Input: :math:`(N, *)` where `*` means, any number of additional
          dimensions
        - Output: :math:`(N, *)`, same shape as the input

    Examples::

        >>> m = nn.ReLU()
        >>> input = torch.randn(2)
        >>> output = m(input)
    """

    def __init__(self, inplace=False):
        super(ReLU, self).__init__(0., 0., inplace)

    def extra_repr(self):
        inplace_str = 'inplace' if self.inplace else ''
        return inplace_str
q�tq�Q)�q�}q�(hh	h
h)Rq�hh)Rq�hh)Rq�hh)Rq�hh)Rq�hh)Rq�hh)Rq�hh)Rq�hT�X	   thresholdq�G        X   valueq�G        X   inplaceq��ubX   3q�h+)�q�}q�(hh	h
h)Rq�(h2h3h4((h5h6X   2508476265344q�h8MNtq�QK (KKKKtq�(K�K	KKtq��h)Rq�tq�Rq��h)Rq��q�Rq�hBh3h4((h5h6X   2508476264960q�h8KNtq�QK K�q�K�qŉh)Rq�tq�RqȈh)Rqɇq�Rq�uhh)Rq�hh)Rq�hh)Rq�hh)Rq�hh)Rq�hh)Rq�hh)Rq�hT�hUKhVKhWKK�q�hYKK�q�h[K K �q�h]KK�q�h_�h`K K �q�hbKubX   4q�hd)�q�}q�(hh	h
h)Rq�(h2h3h4((h5h6X   2508476266592q�h8KNtq�QK K�q�K�q߉h)Rq�tq�Rq�h)Rq�q�Rq�hBh3h4((h5h6X   2508476265152q�h8KNtq�QK K�q�K�q�h)Rq�tq�Rq�h)Rq�q�Rq�uhh)Rq�(h�h4((h5h6X   2508476266016q�h8KNtq�QK K�q�K�q�h)Rq�tq�Rq�h�h4((h5h6X   2508476266400q�h8KNtq�QK K�q�K�q��h)Rq�tq�Rq�h�h4((h5h�X   2508476266688q�h8KNtr   QK ))�h)Rr  tr  Rr  uhh)Rr  hh)Rr  hh)Rr  hh)Rr  hh)Rr  hh)Rr	  hT�h�Kh�G>�����h�h�G?�������h��h��ubX   5r
  h�)�r  }r  (hh	h
h)Rr  hh)Rr  hh)Rr  hh)Rr  hh)Rr  hh)Rr  hh)Rr  hh)Rr  hT�h�G        h�G        h��ubX   6r  h+)�r  }r  (hh	h
h)Rr  (h2h3h4((h5h6X   2508476261024r  h8MNtr  QK (KKKKtr  (K�K	KKtr  �h)Rr  tr  Rr  �h)Rr   �r!  Rr"  hBh3h4((h5h6X   2508476260640r#  h8KNtr$  QK K�r%  K�r&  �h)Rr'  tr(  Rr)  �h)Rr*  �r+  Rr,  uhh)Rr-  hh)Rr.  hh)Rr/  hh)Rr0  hh)Rr1  hh)Rr2  hh)Rr3  hT�hUKhVKhWKK�r4  hYKK�r5  h[K K �r6  h]KK�r7  h_�h`K K �r8  hbKubX   7r9  hd)�r:  }r;  (hh	h
h)Rr<  (h2h3h4((h5h6X   2508476261216r=  h8KNtr>  QK K�r?  K�r@  �h)RrA  trB  RrC  �h)RrD  �rE  RrF  hBh3h4((h5h6X   2508476261408rG  h8KNtrH  QK K�rI  K�rJ  �h)RrK  trL  RrM  �h)RrN  �rO  RrP  uhh)RrQ  (h�h4((h5h6X   2508476262080rR  h8KNtrS  QK K�rT  K�rU  �h)RrV  trW  RrX  h�h4((h5h6X   2508476262368rY  h8KNtrZ  QK K�r[  K�r\  �h)Rr]  tr^  Rr_  h�h4((h5h�X   2508476268512r`  h8KNtra  QK ))�h)Rrb  trc  Rrd  uhh)Rre  hh)Rrf  hh)Rrg  hh)Rrh  hh)Rri  hh)Rrj  hT�h�Kh�G>�����h�h�G?�������h��h��ubX   8rk  h�)�rl  }rm  (hh	h
h)Rrn  hh)Rro  hh)Rrp  hh)Rrq  hh)Rrr  hh)Rrs  hh)Rrt  hh)Rru  hT�h�G        h�G        h��ubuhT�ubX   linrv  h)�rw  }rx  (hh	h
h)Rry  hh)Rrz  hh)Rr{  hh)Rr|  hh)Rr}  hh)Rr~  hh)Rr  hh)Rr�  (X   0r�  (h ctorch.nn.modules.linear
Linear
r�  XN   C:\Users\kztod\Anaconda3\envs\cee\lib\site-packages\torch\nn\modules\linear.pyr�  XQ	  class Linear(Module):
    r"""Applies a linear transformation to the incoming data: :math:`y = xA^T + b`

    Args:
        in_features: size of each input sample
        out_features: size of each output sample
        bias: If set to False, the layer will not learn an additive bias.
            Default: ``True``

    Shape:
        - Input: :math:`(N, *, \text{in\_features})` where :math:`*` means any number of
          additional dimensions
        - Output: :math:`(N, *, \text{out\_features})` where all but the last dimension
          are the same shape as the input.

    Attributes:
        weight: the learnable weights of the module of shape
            :math:`(\text{out\_features}, \text{in\_features})`. The values are
            initialized from :math:`\mathcal{U}(-\sqrt{k}, \sqrt{k})`, where
            :math:`k = \frac{1}{\text{in\_features}}`
        bias:   the learnable bias of the module of shape :math:`(\text{out\_features})`.
                If :attr:`bias` is ``True``, the values are initialized from
                :math:`\mathcal{U}(-\sqrt{k}, \sqrt{k})` where
                :math:`k = \frac{1}{\text{in\_features}}`

    Examples::

        >>> m = nn.Linear(20, 30)
        >>> input = torch.randn(128, 20)
        >>> output = m(input)
        >>> print(output.size())
        torch.Size([128, 30])
    """
    __constants__ = ['bias']

    def __init__(self, in_features, out_features, bias=True):
        super(Linear, self).__init__()
        self.in_features = in_features
        self.out_features = out_features
        self.weight = Parameter(torch.Tensor(out_features, in_features))
        if bias:
            self.bias = Parameter(torch.Tensor(out_features))
        else:
            self.register_parameter('bias', None)
        self.reset_parameters()

    def reset_parameters(self):
        init.kaiming_uniform_(self.weight, a=math.sqrt(5))
        if self.bias is not None:
            fan_in, _ = init._calculate_fan_in_and_fan_out(self.weight)
            bound = 1 / math.sqrt(fan_in)
            init.uniform_(self.bias, -bound, bound)

    @weak_script_method
    def forward(self, input):
        return F.linear(input, self.weight, self.bias)

    def extra_repr(self):
        return 'in_features={}, out_features={}, bias={}'.format(
            self.in_features, self.out_features, self.bias is not None
        )
r�  tr�  Q)�r�  }r�  (hh	h
h)Rr�  (h2h3h4((h5h6X   2508476269472r�  h8M Ntr�  QK K@KP�r�  KPK�r�  �h)Rr�  tr�  Rr�  �h)Rr�  �r�  Rr�  hBh3h4((h5h6X   2508476268992r�  h8K@Ntr�  QK K@�r�  K�r�  �h)Rr�  tr�  Rr�  �h)Rr�  �r�  Rr�  uhh)Rr�  hh)Rr�  hh)Rr�  hh)Rr�  hh)Rr�  hh)Rr�  hh)Rr�  hT�X   in_featuresr�  KPX   out_featuresr�  K@ubX   1r�  h�)�r�  }r�  (hh	h
h)Rr�  hh)Rr�  hh)Rr�  hh)Rr�  hh)Rr�  hh)Rr�  hh)Rr�  hh)Rr�  hT�h�G        h�G        h��ubuhT�ubuhT�ub.�]q (X   2508476260640qX   2508476261024qX   2508476261120qX   2508476261216qX   2508476261408qX   2508476261792qX   2508476262080qX   2508476262368qX   2508476263232q	X   2508476263328q
X   2508476263712qX   2508476264288qX   2508476264960qX   2508476265152qX   2508476265344qX   2508476265632qX   2508476266016qX   2508476266400qX   2508476266592qX   2508476266688qX   2508476268512qX   2508476268992qX   2508476269472qe.       *�<�)�=8)��o5#�-I=LV�=!��2��-o=�ߔ<����8�{F=�*׽ N�h:�VB<��<�����F�      �ִ<�����Q ��=��߯=�7����<p˭>�5U=ڭz�pt}����<��=T����n�����d@�=�,]�>6��-�Y< ��4%�����Xb.����=n[��%:�v8���z;2ҽNï��ly�<�>������;y��B>Mi%��R�����FK�9�����W<�MϾk>Ā��es�Z!��c�=����Q3�����=��N���>��@>��;�	"�\W��j��us��)ɽ��=(1���Oɽ�`Q�!�>fF<
��=b���ċ`��!�;�?<�U�<o¬=�<�a=3�b�g�R�Ω =`v>
�ֽ�w[�N���R�=��e�X����KU=`��=����4�@��ɀ��8�=��=[C�=6NE����<g�#>��=06�<UB��b����>��<�2�������>&T8>�.`=^᛽'���Č��!�ˇ=�Ϲ����9�e��x�=-t�=-(�=n�=CX���e�����e��G=\���^J���g�t����>�<b	�<Gܮ<�:�=���=$�]<`���S=�kL>�V7=]Ye��(�뺎=u���˛�=;9E<�*+��������w>�=���D#"�IۼD3ڽ^��<��o<a�;�̄<v}0��g���|>-������^<�D��>>~^�d����
=e)����<8o<�2<d �=��|=�/p��S���f=�D,�{�	��k"����=��(>��������F=�^/=n�v�Q0�0��;V�ս?��=�<'�<�=�v��ay���a��w��]9=��R=�@o��֥�)" >/������$y�ŵ�=�������Q!�]�]����^>E�h�������=C6�<s�Y��u�<4�ʼ�9&�*�-�d �;{>=�u�=G�3��ϟ�=Hûi�9��g=V�<�k=��=���)>���=�m+<���=�VV���(�����f�k�]N��R�>o���yc=C�Q=ŝ�=��-��s�<�7�;�S��U�V>����'�=���(�����6"��k�>30�=a/��	=��<��=1�L=ڊ<��Wd=۪
���[�F�O>,!�>�kX=$�E>Y"��^F��x!=�����>kcP���m��8�=oY?��.��!1M�~�O�|r���<�1�;~t+>�&=��R=1�I��V���P�<�iy�8�)<2��L�<��R>�R��+�5>�:�=1�0�H̾<J9=wj�=��;�_f>���=X����\
<Ũ=�.B=�t��Ӎ2>�5%�f�O<$��=�,\;�7�w��>�I�=�@�=�VĽ��޹��?��2�=ɖ�=7b>�*4��>��=���=�J��<]��m�Ϗ���e;{�
>4���<���=C�=��O������"��ky�%˼=@�ν�O�=���<(����=^ܛ<�
���3U>�W$�Ʌ�<R�<���=�6X=���<)'�=�kw����=Kk>�i�b⻷e���=���<�v>7��c�������4T�^a�<)�e���$� ����d?���ɽ!��>EY|�����[t��#����-i=��'�p󳽉��=�k�<s�=t���FZ'�"g$>��<�񅾣�̽��eb<�^�=GC�Ȼ�Y��<Q����?��X�=���;�{���I���P<�$�=֘�=�t�=�f]�7�5�P����:>KB�=�F��<�=��#=`��=S��x�=�E���>,^z�)�>��=�C�=#��ɹ>�<bQ>�S�>@���;� ����=�'�<ق���=';>�iY���
>;�j=%�Ż���:�����t��'��s�=����>L'>A�#�K��=�w<��>��>Ƚ�%Y=D�ټ�s!��^
>}Z_�sC���!=���)=�::��{�(0��p��<���<�-�=�*�ф[�r�0�/���H>g"�<c���l� >0���6I=���=�㵽^��[��<�S�8�y=����$V��{�>�:���ƈ�-U�=Hhe=v�l���&8ٽ��=X��<O�+�ɹ�<㪍�\cM�S��=/��?��_=t�x�*!�z �=�u=F�������c>�@n>5Z�=���:|>�-	���<�K���{�>�o��N�^�P��Q��K�*a��=�����׃=	�����#=7F�;��]���)��4=�������-�c==G&���DR��봽��� ��0�=�L1�ᚆ�@?6���<Q�=�޽�.>�T=��=����\>�LA>+oY�9uR=.h���ȴ=[�����>��o�S=�>aT��'�<H�>>����f�K=��P>`�x>ex��+��#$�=먠�}��=�+��I޽��>�ֆ�t�#>��A=/���oQ�=��;�u>���D�5o>��=��\=�4R�px���P��V��>�+=���E�;��ݼa�E�� �=J�<�->�:���U�[�D�I4�>������=<$]=�`:=��z=�#���A�����m�:<*Ob�@�5<����d���x[��+�z�]o=�tû��n�)�=��Ap�|�=+@#>�D�<���=�@}�*=��	�k�ʽY����P���d��<�����9>��s>^�i���=襳�ZC��v�;�<w5;�n&���û�٬�����`=��}=(�q=p�f�Ǯ�� >�/g=&R=L-:��ݽ�}K=����
.�i��=��=��d<�x����Uh��Y���9���˷=���2>��>%JG>%]=NCV=f��qz���@=!�߽��^���T�N�=ޤѽqU�=��C��e3�v���2�;�X�
�G���ҽ�&=Wb7���<U����=�-:=ly>g=V�#n���x<��d=��=���a!>�Y�=�<M�ֽ5�0�����2�R����=E->���=�5��9���">���`��#=�n�=ۈg<ፒ=|s >2z"<�J}����~�=Kdx�b㰾�@w>	&�;�cB�t�<��髽q2=��X��O�������o=�ޟ<�ȴ��
�=دt=��$�� �=�=MPb���/�S��<�H�/+�R3�`��=��B>��<jc=�R�=���:"��=��>��ļ�d���2�<���L)��>��9>��>��%��4�l�|<;��=6s�=ļ�<sN���9��!����=��-L>�����=���=�	Z��+��A�+��]�=��d��J�=���=�ѿ=W�=+��=�����x�=y�;�z8=�;V>c"�=�T4>�ݽ�m>x�=� �8�>4v >���=���=�7����>3S�=�y�=��3<����q�����e=�#ȼ��켗��=�	=5}�=Ω��L�=�*�]�0�O��=�J��7��=��#;��k>w�;;�p1>7@\=!�!>\�ż���=~�=���;4G��lӢ��yɽ�>��F��(����=uv�=�(=�I��pD=T�(>�OŽ=�<
�3=G��=E�r�&��{j��_�=��H�~��n���X����y����}K>�4��ួ�����	ʽ�\�<4	����ӽHܣ=$PY�N��=)�.>~3�=:=7�
�J�2�}�	���=%<F=R�3>�b�<�U����=%K&�ꐕ=K�=�Ƃ���޽r]]���߹=B%��w�=�v��&d#;�k`�B����^���d=P��=�;�-�l�	�_o<S5��k�#� ��>x ӽ�����7B>M�=F֓��w�"o�=E���>)�Ë�=��)=߽	<,A~��U�1���f=0�ϻ4[&>��,�j=�bc=��ָ��m� ��*���.�x�]��F�ɡ�=�(��λ*�=����Q�=w¥=� ���<�����Lݽq�'����n=$Ҿ��1�=�X=M�>aO�p����� q�=_��>�K>gp�>z��=��=��=	��K�N>���=�%�dʍ=�;�ڻ=�X>�Z���ϻ���=������'<��>|ѽt"#���e�;=�>�xT��Gx<�O�=ը�6j�=���<{XZ���=�q'>b	�=����>���)ﹽ'/�W�>='�<ܲ�>�s&>�ic=��~<�^�<�>�@%������=>Lى���11e=:n��^�=�G=�잽���=��=:w�=A��6�=���;ｔ=z�=~�7��ة��u¼E�<>~>�E���[�=����8A��3��'���6>��=�J=��ƽ�3�<ZŅ>T��=��= #��+>H��=�~ټH$�=h�>��k��a�<�W>����/�<��A=�b>IT�+MS>?�P����l���5J�s��=�A�=����7*g��=>�V$>𠦽��k��ra��C&=���>ނh< �<l���=�޽�+O��U�2����{�r����{�[�X��<�Q*�i5=B(?>�ʀ��䀾~g>�.�=,xi�+�
��ڥ<b>h���s��|>G����9=�{�f���\l�@�I<w4E��ã�B>��ɽ���$�f=�㦼���=��R�3��=N|d�d呼�~A<<��<�9��{&9=ƥ�;B �=:�d<�~}���E=���e���&�Q>R-�>�sD>�誽��O�:y�<7���;w�>/�>f�=h��=1�t��=�DE=�
5�g�=qf�=��=	
>R��W4��T���Z�����r�¼.ʽ�D�=�ꞽ8��=���3��=�,�<�I��#�;��Q�C��=��!�$@�;Q�3����=�J���3=�"���=͐$�'�#���> �	�$>��P>�F���">�W�=Q��<��=>�ϼ����y�2G�=c�O�&,}������ݨ���߽��.RV<!�罙�:�����=��=�:(<��s���=.�=�7E>�g=� S>}��l�|�j�$��� !=�t��1�����~h�=��q=�7�=�S"=�(�K����zB������;�1>|3V�����x�<
��=�}=����٠�>��2��N������<��<Ɵ�'Lƽ-����f�:qk">��2���	>�*`���D�:0���H�M�$����=�6>���<�	�=��J=u�~=sl!�Go�C�>Ń<|���A�q���嫏�����!S=/h ��*�HM=a᡾8�5>��$;ej�=؊>o�<S摽C��=i����=G�=G
��Ù>+鏽��%�󔲼�����E���$=:�O>�0������Q�:<E�#����<bK���=uEz>��>Hd�q.=��.��n�=�TϽ������=F�Q=���;�}��=���=�̽�ڼ� =!>`�=>�ż5�{>�s��_�=�U�<r�=.f��=����?Z=t�Ž�m,�a�U��r^=x�0=0
�<6��<3}�=�۽� ��攫��t��(��=��l��a>�4�<��2��&!�v�=�==�2�WͼΎ�=0�Y<b��=�<��q���)>�U;|bK��/�Ee��W�Y=G���>1�	�5��������u<��;]@>n�\<v�g>q >�E1�����aǾ�T�=���=19G��������:ka�=��=TѼ�Q^n����=���=.%�~�?��?�=y�ýd���h���	3_����fu$��� �����zȽQ�(��6�=�����k˽Z����u��!���͞�<#+��z<"H="��=��F�^t�<�*�=ku�
�,ҽ��m��^d>W,@=:x�=Ӟ?�]�V�㶰�e�P�e���}6=]�/��=��>�<��a<�7��� >�P�=Z_=�t�=V�8�EFW�������%�r׽�T4�9>����+��=��'�=����R1E��*���}��I>{I?��OE����y=�ى����=Y]X��l��>u�Ľ��Q��9>3û���<3tӼ����\J�~��=���=JY<���$�>P���U�f>g���w+ؽ��=�������<��=צz�Ag1>C+���G=���<�"�=��>X\V>�M=�r�>�B�1��'G �J��� ��<=V�<������W��	,�=%�,>;����=՛�<��q<T���R�>�|9������!�n�L�y�[��g�=/��=d2'��dĽۋ>���$�W�=�K�=ɕ�x��=`�<��˽�����T����[㻳э�Ȟ�=��;��W<���>��<>��=�=��ڼi�ѹTPI=Kv<�=���ѽ��������������M�4?��w)��1��=q�=&Ӽ��>�t=�a襽V�ཐYֽ�ק=�A9�����jM�ā�?��=�{��G�<�컽��=j�?=�D޼���=����XU=<ϻ>ZƼG�����<�>��i��a�Ds��l�o>r6�^X��H��������=ZQN�<���{�=���=$ I�2Y>z��=h��9�gm=E�]>.2y�H�!��C��j�۽�s�������,��e�=P�N�������FY�ez����=��:�P�=c�������O)��>�[=a�F����n>��+HM=<7�>����*��Ł�Hѽ���-M�=��T�-�߽t8�>���ڄ�=ྃ>c��< ��=�`c>�Z�<�tA=�ޤ>Kx=|T�<ZK�>�����!\��>�5�*��e�����<j�<z�"��?J>\��?��'�=�c4=�;C��C1=�e�`��ԗ(�xP=�����g�$������O�м��;(���!��r=��ު���x>�Y�����<���k��=7j=�"<�<�ĝ�a�=����:�S����̡��E_�/#��kĸ��>v��ۼ�:�<0.7���{>F5c�Ȧ��~���ƽ�!��5��,�=Oll=��X<�[彪����&=-���AW=���<�-ݻ��9=��5=�]
>	,�=�\1>xgӽ2p�=�g<���=�t�r>vї��$��B<9��뺽dZռ�Q�;ppw=C.>z� <.?�j1�;���Fd����36���׼	�(�_I����ҽ,��E=��kD<E1��_c=��e=}*����9��x� <Ӿ�=���=V�5�殗>�u9�he�<�٦>��$�T�@B�>��)>��v����>칎=�½>�>:���AK���>>��;0������D�#=���=���<:g�>������WH���-=����mD��0�<Z������Yh=��Y=g� ���&��@>V"�����=�@�UgL=������>)�=M����:��;��`�;�>�b�>8�ϼ��d��!�֗�=��=���Iw��
�>EQ"��A��w�<�`�u�~=��=�f	�,��<C�_>6�8�	C=��e=�A>��r;��:������<�c�=Ȋ>~��;�Q��B@�;�xr�ֳ=&_�ۮ��>թ��77�=���=Z	ؽ��(�/# �>�(�Y��>��<r��<ĒF�e���J=���=�K8�����⽕)l=x�ɽ��4�w�<��K��<)�<h���=yҼ�1�=���=�3F=oCH:X�=	V��U�>�@*�)~r>3��m�s�o`>���6\��1]�Ѽ�H>p�j=�e>ga�<�py�cJ=&0�<����н=��=����]X��z�=���ڼ�	���ؼ�M
�H�<��D>���%%ջǂ�<l�=��L:��+� �p���C=D����l����E�医<������J�����=K�'>��I����������=*e�n�=�ݽ��G=D1=QF�����>�h����=ۗ/>fX>� =�qq���?>&\���&�f�>XI����
�_M=���= Q��c���9!�A�"=5��8�=����#=�v�=�a`=�;=�����1B>k�>X)^=��ƽ~0�<0[:�@�=�O��+����>e��<>��ؽ��=�(A�r-����<S�/�q�i=��>��u=�&>L�5�)3:�$\����;�у=W��I׽M�(�u(K�u�=�E�<lt5�y�<�즽���/�x��<���K%2=0�i<5����$!>c��<�7>�-=��>5P�4�N�ʐ�������h{;Z:e��e�=���=À����c��L�=W+w���N���=�8T���4�����I�t�>[g<�b!�9z�=
0����.<��>���=5 D< ����+����#F�=W�ƽ
$=S��=ʭ�=�W��Q?��=��=G�<�vUN>�����Þ�s�.>R���9�w������F���><�v�=ϰy=?���q����z�H��=�xx=�q>OE�B�O���=�4�/�;��I<p~M=�i��7$>�_�<L�=�k{�&��L����ib�q���*�=��<X��<AH�=V�]��3��Zӽ��2�J����-�=���k�=1U��'/>�>H:&�0���D�S�>}�U=��2>z��'V<^x���$���7=��/�����= �>�\����>��C>��/�_]�<	3�����=� �S�M� ��=��߽S=��n=��e���3a�<��｣���T�=��n��U��]6*=F�=7M<2��;ai=��5=Tʓ<��?�`ޖ>MW��%=ټ�=�G�=��'��̽�L�=�!=�b=bQ>�>|�(>��J>�����ُ>�YK���q��,��@�=�Â=Bq3�����f���yQ�X���_�=i.+>��=� ��x;Z��o�����=�ھ=�=���F�=��ӽ�A�"��< B��iR=�*B<�"�V��=h�=��'>v���>��\�o
i>VB[��w��=G4>F>�A.=��=���D,=�%�yb����棅=� A=��=�8"=1u <�ه����T���� ��N>�2
>��>�@=2HZ���+=�=֠]���R�h��=n�;"~��zG�5��=h���?	n�?�?���q>Xja�-�5>�+>B�f;p�n�h>��=�H�;fJb�����f>��=rg�=]卾{�Z>�0w=ء��b���w��=՜�]ԅ>Bh�=�r�}�e=���=�f~��I�,��6c=��a�=N>*��[�>�����4>~x�s�
��79=��=���=.�=�[��߯����=�[�=�½��<gȢ=���9�(�F<<������`��0�=c�B=k̪�yܴ<�����ֽR0��&Ym���P">Ƽ�}�<�L<�V#�AR7�:D�7P�-�w0d>}�e=���vp�<���=@��eE�=e����=v�P;+-����=�X��+�=ѵ�;�>i��=��=�
 ������#ʽ�(����=�W5=0\B���=mn��̨�=�tA>���<�<�N���ּ��ɺȽj�Y�����>�=?����r�����j���Խ-�=*��,ὖ��ؘ>���=|��^��4HȽ�b>�A�
w>$L=
Z=eP������7;㷨=�=>��r؏=���r�,>�������ck��Y����>'��J ����=3Nl=�ƽ�F�����=/��<;I^>���VB�u9�<c�A>���4B�B�|=]7>T~��f5��aXN��2>Dv<>F�=��>y|>|o$>Z���(8=�s7>��=2���ꊽ��oO��	>RT���J��_���'>�W>Z��=�m�=;ف>Q8Ｐ�=��W=gh��Y��	�u�q��Ǽ��`���J=�3佮�>[�<��%�fs)>�J��"�<�����=��D�҃�;��;$���$��x��<am����o�5���O$����A>u��<F�T��?�J>T@6=�7�<��p>(�<^3��:83�1�q�	=�[��xY�`��>�^��)�Z��Yt��O����6��=ж�=LTY�RϽ@�ʺ��"=��&�fY>1�4���5�q�+j�;S����=u^��B0>�j�=VY�=G��<9������E>��߼���Ch�=x缋.�=���;C�<�p>ˎ-=��=hֽ@h̽։=hI2==�2>)�<Qp����4�s���c�=�v>Zـ�X6*��!*>��G>'����A�=g-ɽ�Pļ&*���+����=�,��m���=���->��3>i�>�'����=D�û#GB>h�=.P>����X�ǹ�<�1>f-�K*��2pV����0�E��6�����/=���cX=\c���-X=��Ľ��ý�b�:xu��f�{%= .���O>q� >�T�L]>M?��s>V+6>�u��.�=�ԻD�˽��\�`+սm㼻�2I=LX=��Ƽ�f-=�9�<=j������hx����b��
�x@���T��ݱ=/\�=��c= �T�O�F����+�S>e�=��?>4ؼ�=45�<�d=��ʽq����>��։��L#���<�3�=�
>���=�ƽ�y-�#᜼��V��Yb>�̯�K/v<�o=o��<K��<�"�b>>C�9�2�@=� �=l��=�;y<{E&;��:� 6>�� >C#4<k���==� >��=�1>q)�=Ц>/�W<�S;�	=&	�5��,U��.H=�<z(�<��>�̹�fj�<cnG==�����oY`=x]��@��=��ۼ�-
��� =��=a_A��;M=3t�/�>Մx���D�����dz��������=�����W�����<*�=o�>J��=Cص=�A=���=p�$=ߒ`<�ܚ�أ�=)K�<)_�=�+t��T�;�i=��)>�G�=�}��������؀���A=W�>!�t=$%�TC��-��<2:�<�Gi��H ���,�w�������F>�s=/�x�b�;�}�<<����,�=�|��|���<H\ؼ�>K��:�=Rk'>��=���;�+�;���=U��Y/ǽ�ʔ<�Ș;O��3��;����U��:�'������T3=E�J>4��70A>@TG�K��<Zk�>?+�=miR=�$B==|��M�=��O�(����_>m-= ʴ�[�y���<R��k�=���<H>�C_=%f&�#>��[�]ſ=���=��>J+>��4�1�=L��=~�<?�e=y;6�W��=j#;�� ٽ���F�ད%�=�:�;Y/N=Q�=��r��u�S=鎻��s���{�$�@>�\�=������t=�0�nUx�S�=/�>���;�'���)$>�=����f�� �T���W��i���,D�
���FE�W��<�~�<�c��?ef�~+w>��_�Ɓ.=(��>�U&�?|�<d9�;��������wD����=*d&�yZ���><`�+��ֺ��E=G^�t\�=���=�覼{�=qZb�#̥=^���k�=}�a<�9���U�f��_��.��=i\����R��Y<3�p�p�ս�F>?���}�Ƚ����kP�V��3
�<JN�D�Ҽ���<zf{=�[ͼ��_=3y۽枽�ʝ�R���
=��Ef���%�O�#>��!>����>����|��~�	�Z��쑽t9�3��<J1��R2=;3>�d��r�=�	>@3J�9�>ٚ]��x?=_�X�O�1��,O�jc$>�R��79���ր>��4>U��<�w�=M(>��=!���<��b�Ӈ*=� ?oً�m[�V��=J��^<��������gg�����\��f��;�zd��Ё��;�|f�Ӭ��H�)=P�4=AV������W�ͽ�F;>���e�>����`~=��?��ei�﷔��$��o&$��4���d������=x�Ƚ���{�"��9>�
ɽ~�"�|���W������O�إ�<�t����<��0����=�h���������1Ž�J���9/�LY>A���/!>,�&�`��<�s���9�4��g;Z��==k��r
������A=^%����=_a��x��Ӿ<����I����D��&���z�`�s���U�";.�,����z���V�=CVW���*��X�=ᝢ<�/���<����1d߽ޙ��sf|��x�F�=��2�d��<K>���8�;���O��:fU�SMT����9������D>]�9=v&�<�͉��>FP�<\=>?�kC>j#f>���=��U���L>z�Q<Q\
�1<�=���>!��=��>��'�Ipؽ��Q�N~�>E��;Ը��l	�o*�=3�>H�;;�ؽ�� =ۉ����=�t&��Þ=|�	>�̽��>n�����Ulݻ��=6'�kq*>_�|�e��B��;�M��.�6�H���uKQ=$��?���,�H�b�����<��p�so=��'�켤�T���=��|���]=��;>�_$��_��f�k�T=��ݾ�*>���g1����;�  ���=��u=}RW=�7�)F�M嘾���^�����; v>tc�=�S >W�=�꽼�)(�0�+=��&�������Y���W�V6r={��=Ő�;H�=���=�X���Sw�sZ#>���Y򿼚�@�/y�=�p����=T1�=#�U�!t�=e槽���+	�rT��bƽz?=ޮ>�3
>:�>�r��sZ�Q1 <i+�S�e=�^�OO>(i�N���U���F߽�x����<xA�;Im���J�W�q��h�="v�;����nB@=3��=��I�-���g��sE�%������=�5��S�4�����*q�=����^���Ɍ=p�=G9,��C�=
�^>�!/�=�&��C�=��>c�>��C�Pd��AżdмL������f�q�9P¼�ռ�?���s��C�=�f�ԙ���(=�n��ѵ�{a��q��*%�=����ٺt����> )T>���Ƞӻ��1=��C��3>U>'����P�N'�Ȫǽ$RN��>+�x�R��=e_�=>�����7���<۰5����ϩ̽�0>a~��,V�=��<hw8�@X<��c=�����(�����iF����xQ��)��rh~;�$*����=ޭ�<ܝ�=���=��t�o߃���<s*����1��� �=�����>����[�9�Ϻ轵�>�UZ~=�M�>�&��ֲ�����M�����q;�F3">
X6�$^>X=@e�<�^d>�<���>~̝�k�׽���=yA�ش½���<���ߞüE�Ƅ~=%�E=�͘>�v��#ս.H�<^��4�&��˾��څ���b<ɖa�R�&��=����=%�>>6�'>C^Ͻc�=d�;t��<�w�=��=��s��>E�Q<���ܖ��'��=���<匏��A<�d�<ƻy�����~=	N��z=1�鼟�z='%���u>��e�Ix��_=��5�.r�ԧe=��O={�|>_=+P��#�=����q>D]l=劳�Y��=J�"=]<�=3�+��i���n�=��<Z�=��L�=���B�F��,>ܱJ>xiһKB+��F�=��$>͎ ��o���H�ZR��K�����H�ٽ�$>�@>&*��lN��N�(ī=�M=w �=qݮ;S�=e��{��8OVν�r<�����"����P,��Ǻ��ˁ�������;�t��k>a5��$3��c�=	������=d>��<n02���<�Q=�q�N���=ڗO�L=�Gg=����їP>�E@=ys��'�\�s���< �	�/���@M��üW`߽I��=,DλF��=[�>}�C=�S�<W���9>�R�=��� 0 ����=���I�=H�g�H��d�!>4��<Y��>��>�F[=G�=U����<q�綍���o=��;>�/>��.��Qr=�[M�v�/<\Y6>,t���R=�b3>�ѽ��Ƚ��(>����7��	�?�a�F=ԅŽu䓽o�}��==��B̉�ϴ�>�k���q��;0x"�u佊HI>Ka=��*>���U�9n��=w>(@=��<�<݃<(�ý�Jڼä	�C�D��R�lײ=�v�=�k/�I��<-&=shD=�%���E�<��c�_�p=�����'�=��6����;m���Щ�;�����A >��;�	��vn����ym7������&ּ?>t�U=�q���xv=r�=��<t����K���u�="�=��H���}<���@5E����=Y4���x�=^�
<4�>�Nż���S�%�u�Z��J	�<�T��TO=��f�; 7>< �=�8�x¼�ظ�}>xN���=յ�=�澻t}����#�':�]��<�����y�����<c�=Æ1>��>�f'�O�=�Q�=t=�=�:���2���G��>i��;_�>���=       p�&>���=En��m�ٽ�H>6v�W0�k}޽b���_��Ѕ�c��9$���
���7=�ՠ�$Z)=-)��NGݼ  =       �X�?�n�?A��?d��?�q�?���?Rk�?A��?ٝ?≯?�-�?�a�?8ԡ?��?G�?���?z�?WW�?���?�C�?       h��>8>�U>1mS>2P>#�<J.{>M�>�g*>\,�>w.'>��>+�P>A$�=�=��B>�e?�&�>S��=�9>       :ur?��y?���?��?E�y?�~?/5�?��?�.u?�ր?@�r?=�?�R^?x�u?W�?@�o?�1r?W�?ǁ?޸o?       �E��������� ��4ؾp��>��]����ᦿa�?ಲ����)�J?�+
����>]���?.%��۶�����       ��?.�?�V?o�-?��?%�?�A�?�}?��>9?�f�?ӔF?U�0?WD!?2(?�k�?�QS?�m?"��> ��?       ��,>/�=%�������U>٢��*;����w�ֽ(��>�޽������Aݽ�U=�������<�v����̼�]�<       �;3�:x�^:%��;���;픙;��u:���:�;��:���;9PU;��8;��;GH0:z��;�p�;��7:>h4;�*<       �%             ��=�����=)�q����� =��;W������2�ƽ���'>fiͽpu�=(B�=�Ή�=�7���5	��m�=U8�       �w�6��%M�����ɘ=���W�����;���z_�=��}�= u=�"���Sq��9*=!_-=5��=V�d��HA=��E�       �K�t%�=F�1=�(>��i>��?S��6=㫴��v�)f4>�]U�� �==� �=��0<>^�=}�\>f��=@	�>      ���=b�=�|ҽ��<D������=̊|=�`˽�j<e]�=�8�7����1��cJM����;4�'>�5�����=k��u��W>�x�=~���n�g�bE"����l��>�k���v��� �
=)ڽrT@��l���
,�þ�<�F4=/�s>���:V��Jkl�U��:�؀�	O�; �p���y�̽����e=@���ղ��r���&ɼ�%Ϻ�L>-�>���=@��g^�G蘽��=N�����>�1.>�F�<>>�2<	I<�6�=7~���MS���O=�6����M�=��;=�(9>��������k����﮽�x�=9��=7Ⱦ�".��X3���"=��ƻ��=t@F=%gY��]e��>�&JʼR: >@0=����U>���=A���*4�SUӽ��8=�T��[��=e\w��G�>�vC���m�j�&@����=奔<?�нd?�YW�='A.>��PĽ%d��Ш��%�<Ԁ�D�����=D��:�u���y<J����Ͻ'����>m�=�.�9�W<�*U���C<�|��%�ʽ@*�=�uJ�5�k�Mґ=���R��=l-�<Ah�o�x��lx��{<R� �%�9����=U��ip漍P#��Μ=��=4�(�(���e>Y���W���B����=.W=�l�<C^��!�<Y��>��=�Ŷ���<�i=���<�[�=��Ͻ7�%���)=uJQ�H�=���O�=�^z�ˣ�=���<Bג��W��6�<h�>B��<���`M�<��L�]��=P̌=B�=_����<i��L�=�aZ���=�Y�Z��*���:��(<ϯ(>y�`>�͓=O
����a�>���<i�<I	>\;%��\1��w��$�� ;'烾���-B�`1���&9>W�*>�T=l��������P���
>p8��o>�!%��'[�� >�����>��"��y����<xY!>ws�=XJ��^>Gz=ች������:>{��=<�<h�>�ѽ���=Ċ�<��u����<�=m=*�=��>3��=�8�=#o�=-?�<&���	4�>�	���<��>n3�<(��=�2���rv�ݠ�<�[�-�=�g>kH=`@��S��;�}4�ɥ�|N�������=�4��C��G(�<W�B=�6�=��=�U��%�u����Y�OK�}wA�X4�<&Y!�%�=�&>�U9=&���q�=퓸=  9�5�Լ�$� DX���=�	���yνf���@"=�.�c�=�1�=m�S��>w�$�D�=��<�{�:��н^I�����=bl�=�>��t�� �:y<u��+O=�k��z��l׽`I�HIH��t�=�λ<��휍�By`<%�P>(Q6=f��j�=�}b=mR]��'��7�=S���ݢ�:d����<+�H����=}.�=c��J�ؽ�JZ=#��>#L�=1wQ:񃈸m{S�z���I`���%�`=K�3>(�>I9>*쑽��==���=p����6���>6ꐽ�W>����.Sh�^�:�^�)�\�U< j��(	���>������<�~>����<2Z�=�H�����%۽C�����k����C��=R߽"k�j���VY�0h��#H>4[ٽJ��>���LL=\�L�?J��/=�>�D>�Q��1��A>=���.S��d��<sb�=��x�5�==溽�Ԕ���v<���=��=j>��<�[��ݨ=�1O>O�=kD���-����=��<V=��=����D!���{�#5=��<l�>�Gռ;���&=A3>D����f%>&����0�T�ȽK�
�<����b>����������=�m�;���=�Y>�Ў=�<}�=�l<>��I�\���h	>��I=Y6�;H%=��N�<����׋�j7����W�p5��Q�JM�=��0>�b�P�轳�<;7n�����;�lֽ�)7��b�Kz���B�D;�=vl�H[��t��0��=ZR�ߚ=�9=�(�<��=�i��q�=�R�=Z^P�v�->���=Yc�=��9<�q�����=�eL>�
^���;�"��p��9�<��A��s�h����>�=�q���<�[���-=~]��M�<G�;�7���-⌽HX��\�=C3���X�<�;�9����f �0z9�Yӳ�aU�<j!R�5~��;�=��<�@2�� �,10�!k<i.�����=���H$>��R=`"��P�=��m�*3>��]
=p�ܾ�@�=PZ�<qj1����=JOm�R���͛�<b���S�j����>��<|=�����=�.�=�o>����צŽ	���|�=��$=A���Rf|�g�A<B�A��t��:=�D��>�,>��V=�tl�2}�=�jɽ����_T��@O<Drڽ�v�=�ٽ���3��=��X=���<hn�=�+�=z��=�8���_ὓ��~F���c�fX�����^�o�0=���z�=Nճ=<?�=���;�&�=/�G�6K<>��=ڌ�=�>�dս�pK;y�'�
=\�Q�|C�p
��%�=|�ɽ��Ž��<=j�=x�="�"��}�<��>���<���=�C=�g���@c=�b�G��ʍ>kY��o�=j �=*xＰp���L�=��۽.��P���������@! :����)��:��������=�b�S��� =����;d�=Ӻ�=�Y��b=���=8�">p�=�)��6�=�p5��_D=����"��~W*>��=�8> ���������>�o�<��Ὅq���c��i�@=��*=�e�<��-r>�Cc>������;���<�!<�s��=[6R��<KŁ>����Ǽ�)���V���C�Ͻ�H�������=R#��x��r9��7�|�b���l��4��?;���>�u<~��C�<>�@<�wt#����=���=�S��>�4=_5�=(��=ŭ������=�R��x;�?=��=�ɻ@۟�Ǎ,>Y��=�=Y{�=Y����=vOB��2&>�?)=)ɗ=)gV=�86�Q��=o���I9�=�4���Ѿ(d���[=�o�`�l=<�J7�H��W=�0S>+a��	P��i�J���mY>*8�� ��H���<E�=�b��I�;W+)��C��a`��1p��p� ��=����+��{t=�e=��<��'��(,=�|���ӽ#�?><%���/<%Q����=\��Ŋ�=����gV��M��锫���=TYI�������Z�=�K?�:A<��=
�=vd���E�<b-s>�ϥ<�z�<>b��ف���$�=�Lu=&���A�<�D<SY=�0�8��FǼ=��=^N�<�,���)�X�����H�ي���>����/=B�?=�ֽ���	>�8&�=A>͎V=�G>�����=�cR=�.����=>H��%Q)�e� �=�o%��h�<��c�ӽ��5�.p�=r��:y>U�y���W��fH=8=V�e���N<]���z�G=l�'>k鋻��������o=ZC��_�㏏���=�?��}��J�K=e�c>ҏ�^ƽ�Vؽ�u����=����6>�Q��'���<t~ �x�*<!z�<���P=G�=ص�x�=��R�+���n<�=d����s�4d������=8�e���;��[<B�=҄�x��<�y�Q_�=ČɽV���a�=��<C䇾b�>xE�`����KN;��μNG~���4���0>���=C|�����<�<���=��i�(����q����2=9�==9���/��=����=p��0�=u��<co�
����M��\���c�d���=�em><N>�t�=ׁR����=�]Q=>s��G���t=�'=�q�=G��G
�����=�#+��[��D�=̼s��=��M��`B���Q=4��/�9=U�=�}��[�=9;c��_}�����a==�g>xm���,��R���pD=��	�޻�;�\���@=`��==��4̽�)=�Ӫ��Ͻ�,v��+����<:S$��=>/�=,�=�Z=�cg>H�%��cC��|�����<�é����_����
=J�k��u<�[��y���BԾ�����>����0��3[��6<>�B$=V��<���S��|��6x=�d��#�}=���0g��^�'>��@����<�3�(ʅ=9�0<���=�
��+"
>��E=4Cq=j�`I�<6
?��`C>�o>���a���%>��ѽ��>M�ټ���+��&�C>���/�;[ņ=�4����=Y=4��N�<2���/~ʻ�k	=��L�n�\�r�;)��<i�'<y��5������!>f�*�X� =�읽���N>�&����<���=D�~sD��=[�?u���0>)~�bq9�SU>�f��1��	=��c�A���m�� ׼��O=��L�&9����=>�= ��<5�%�"�T>
콵����.>�|o>&5=6��=�2>�,��f�>��c�o����X=�J�Y�>ey?=62>o�	�[+	>�( =�̼39�7I]��O�����<�C���=9v�=�h�=�
߽q>��$>�/��ڔ#��нΉ��e��đ��n���<���qb =�|ҽ�b;��½TO�<�� >�+L;N�T=1�>�o>��3=�ib=��K���?�<Ǟ�0폽G3�<�r>X[�=�`��&��ٴ�3�ܼD}޽|,	����=	)ڽ�7>ڥ�=�!���=�M>8���N%���T�p�{=� ֽ#�=;\�<G�彰�F���x=����_��Z��%U�dY�,�=�"庥�#;}TԽ?����y���kw��B�=3�> �`o���E�]��=�E7��� ���>͗ü֋����>�/�k�##�=Q V�������(�:��-�������k��<�>�>�ae�r��=4T=�K%�Z��<G=�S�UX�<.=��rz�*��=��>VD�B@�q�<>��[���>�Re��F�a�5��yؽ2�<^D纺0=�r�e�>$�]�)����>ބ�œ���=9�="�k��;=����X�;��=�o�Nal�B�F>D&|>�bu>��\=W����	����&���1D=��K�0p��JNP��s1��i�=�_a��tϽx��=to�<W���i�=O�,��|׻�Y3��S���=�%�����<��F�O���x��!�=M𔽋I��W�h>�\���fZ�ٕ>X >4"��_��=$��9=����hl�A������=�K޼����;�=�B^=�����.�=X�=���I鰾8��ćq=E����= U=CF½g�=�b��Z����eM�8E>���;y=��`=9̽%����Lc����<���;�94�k�->!�J�p��=��=�%�=w��H���=>g���=�Լ�񓽁x>Ȥ}�4Y�c�;X
�� =�>#_ϼr�̺wI=*d�=���R>>]uk��7=��=1Z��%�x:=�����Ž�`/=�M<�9i>-��R���ͫ=Ċd<;���l=}M�=P�=C�=BV�=<&m��`< i>�x��M-��x�n�Ƚ��#��#>z�=>Q65=��ɻ%��<��>���VF��=6}b=�덽����-���zL>S������{|�����"��_���@���;:>�Yý[99>->���L����=�����oӽ��g��vN��:���3�=�w)�'��=&˘<ּ��kv�,U�Ρ�,>{�Q>��=���=��=�f>{�.=ul�=�^��F�<��?��{��V�=U�U�y[=�F�=�޺=$P@�y`�Qb9>%�=�J>]� >m��<�oa��ӽc���u�=��
=�I��w�j=�{\>5���*��NX�����=厅<�T��i&Խ��[������=z3R��LJ�F��=`5�� >�߅>��<���=�R���!=52d��P�=Tb����=z~;�v��= �8>��=/��%��R����==�Ñ>�!��n6�9J�=�X>[o3�K!.�vI>�ژ=�R<��B=��=�"�)I����!=������=��=uЇ>20=�
���U�����q >[]�����	t/��Z���N�<��<5G����=����5>��]>�k�`�<�YN>5^���	^�V�޽^��;���C8�=�'��L�>�#=8{��b�ƻf�y;苡=�<���ۼڿ8><��+nk=�f�����*�=�=J��=b*>��<�=������4����>��X�@���S�O"j<�T=k�>=�7�=,��=�=�º��P�4��yp=P�(>q5>y�b=ZԎ�+�2��<�Z�\����F>�
�=]]��1-4�p�)>X	M�֕=c���0z��=/P����$<�9�Z��=
8��3�=N�D����/+��j|K=E��<tf<4#>F9/=2U:>�,/�nν���J.a�҂$>��Q��>y=��N>K�Z��>$��<>�=� ����;��9>b��dȸ�>ߔ8�9�=y,ս\��)νK��=�Ԝ=��/����Ev��~�=p�B�d�u����=� `��>� �<��=?9�<�|����+۽ �F�>��h>�����Ӝ��^���>�@����=G�=���YE�|�<H��<"��q>�=�e��Sw�=�9�I���M:�`�.>�#X<��=^����F>b*�<|��J|��(�5=Hv����=1�->�Z�=����V&��!��=a��|=*���s#y�@
!���������ͼF�>Ҥ����z$A>V:���ğ<Q�p�Y����{����q��<�B�K�=e�p���P=�������̌=#m>�?*����<��l=�e����=�+G��������N��=�=�=R=��0�w{�=3�߼��=��N=ť����½x�>��=%#7>�K=a��=@�>�Ǭ ����<�"������
�T�
���C���9�!?Ļe0">��X>a��=���=�@��ց=0f�L��=��X��������Q�� ��ŕ=�[ �t�`�ݼG�B>�fv<���k��c����2���XL�4)���옽���=0׏>"�>*�%>��oY��[m>�c<RZ=��>����U��=JK=(���|3>��H��3>�=���=�씽��n>�r�8m��d���� �8v5����h��7��=���=�ા�����&K�r�>tȨ�u&��Ľ����B� � ��1.=�8�����������4��2��A=���<,�=OI_��R���:֟<t��z�=کo��>E_���9�E�^>�Ҥ���4=:���b=���=DU0�Oⰼ�j�=��>aǐ�;*��͍�k�X�BzN��MK>�+/��=:��=�-?>�ʎ�qh=�3i�VS��
�=t�!��˵����^����"ƽ�%�=���<�e��2��P�>�	<>�5=�������m��=�����(��=�.>6�Y�~��==�>���9��F�=<Q"�,$��F��=խ������D�L=�����2�=!,�>���4�=ŕ����8�Q�=iR����$>��i<&
>f�<f۽=i�6���E�5D=dZ�=ndj=��*<�=S@ >�2�<��-=���<>&>�I�P'�;<��=eK��@>��M=�w�<H�>nж��Ƣ���� >w=Q��=���:�;�=������>e�x=�p�=�h`>��^>1�����=�����f|��x�=���=��?�k��=v�@>w�0=��w=ռ��t�	��n��xu�=	�>������O��=4�Q=2��=w�6��X;; ����=��>!���9���E���ս�Mi>j��=�+>��ս�A_�TK��9h� ?���TU�=��r��[�i�\=���j�<�0>�j&>�=l���Ͻ��0=8y�5g����>']�<J@Լ�I�*^:��g =����M0�9��%�=�Y��;<< �2��t)�a)]����KM�4�=��">6u=~!V�V����M���{;.L>D�.�K%>:���>�G�=�U4�Ko��=�=E�~��8=���<��9��=3���1Ͻo�ܽ�	ݽ>>j/i�������=�z=��
�B.���E�ƽ��_>��S��*��k�d>��d�1��>��=�Aս"�>F	�=�xV=�b����'�q>[�=o7�:y������3A彋�>SI="�:� �=d���C6½�^S>��B>�<�=�p���">�!�<0��s��=���'���L>t�^��K�j��xD�ɿ�=�����/= )�Hiͼ�9�<��=���=ȧ># =��<=�`>�X�=��.��b�=a[[=�c�>��=G)T�f}佻�����l��>>�Z����Լ�.�k��!>�f�=� 3��ۂ�z����o�`�I<�����
*<lZ����!<k���!K}=�1�_�|=D��:��o�dO��;�*>���<`� >焼�^=,�&=���=@��νtI׼݋e��(������$�=�����\=z����5=v���_	��½UJ�aR��N���>�U=<v>�=>
��ϟ+�ݛ��=�C���u=q(��vƪ�!N�	C4��4=cj��ᒇ=�8����z�m(>���=�p+�|�t=)s��۸=/8��wW> Ҕ=�_T�R۴<���<��<�b�a�����~��˫�f��ڸ<�&%�9��6r>u�ļ�����M�$M�����qTb=��+��>x���w�нP��<�t�=i��=���;J۽&��=�"�=Ɂ�=fQ
�֐ڽH��<�z>�� ^>�։=��d��b>c�N>v�[�YPԼ|o�SIW�-xӼ6�1<�{��\<�=���ѻ=RJ��W�v�.A>7'�>8{������g_��]=�jŽ@q�=�QI����s�8`g=�=l��=`��� L��	Q=��y=�m=�$��>r�x=� �b�����<"R�=X�>'-ݻ�sƽ��x�Yg�����i����>�[@�7H�=���j���T>g��0-�Ԉ/=���� A	>-~Y=-�e�/ka��D��~��~��;�s=��"<y4�ml;>5�;gI[<��>��=�]'��t�<�ӻ8p�<�� �%>ɣ1=��ļ�E���ҽ3 �u;V>=�=dj0=Lk4�xb�b	���=�R=T�"�hK'�V�{��Ŧ=�a$>�Qv�9�%����w��L�����=4��=�Wʼ/t侕�=>�\=�@���Aɻ�7�(�,��J�7Gj������D>ћ_�0�^����>��g>eQQ���=t���0�_G�@F@=Q��<#0��}>��?=:��[�ɽ��F�ߋ�*���<�:���Q:�����c�ɛ��>!G>?YĽ-�(>�W��`Ky��a=�J�<�2l��S�`��-��=ǅ��i=gH&<0=��ս�}���ʹ��W����=�<�=��v�Ə�=�F��.�#>�a�<:��̼=��Y��>��>;	=��>G�;��������vM��J96��1�>T�=��a>���=@�?>�c3<�m��0��*�F=g�<Iu=-G'��r�=�"��*��=�Sܻ��F�7���	�=F	C=�a���=jx<�>��[�=Ά׽�
$�>���'&�	U�;��_��b۽�]�7����o�:����6��ҁ&�M+>����`s�Bc�<ܭ�">2<b^�;�%z�H�=�k��&�<,Ƚͯ1�����00�~��<�6>X�>�>OS��x�=B�!=.���\o��������=�P$�0A<�9r~=�hq�"Cս6��=�n=�rڽI�ٽ&_>=��=3%�<~��=�T�q��$���=��0��=��$���p�����M����>��L��e�нz=�X?>�B��b���A��>�@�}�9=�E�;�d�=+(����[}���>�	]<��n=W��<�k�=�=�`νET����TO��^_�=X����4��D�=ͼC<��ɽ4���a8=.���-¼6��=Y��>m>�IA�B���J�<sN�<�=��PU6�l� �hRY=�8����6��>��>�=�>ۋ/>M��9���=7N=�_=�:���~z�^t[���>F�6�F�ͽP �=_�f<	�3��=�D�>;�@=�Š�r'=�i�=
���~�����=��?;���Ȩ�w�>0��=4��<.7==|�<���=�	�:�հ:1=oԆ=�]�=�� >�󼐽=�&B���5��m.�'����~�<�n;#i�=T!�=p�E=�UQ>aZȼ��=e����I�����T���_�����F�b�y=̣�ө=s�=�ܨ���>	�<^��=p�=L�"=�0�=B$>�2��Ё����M�Q��<�K�=��=��k=-�뻸�������<�=q#'>���=�x�;u
>��źN�,�P+b>+����	Z>I>�꙽��}=	�k=�e�!(��[��;���=IO��o�'>.����a>m�<��"��RU���U=� �K�B�
A�=��=�>��/=)��=CW;>�3>#!>�'�<*)>���=���<��Q�	_�<ָ׻XLx<����h>�t�=����Ez�<Bx佁��>",n=���=���R���������=���=q�>Z�<�����=��N��1>e!>�O�Ɔx>:�y=�}>���=};�=�{<Y�P�$��;�>=NB�<&=du�;%O	>��<Q�#�����(�;Iy��u�
�>���U�='Q�=$��=��w=�9=��[��Ĵ=�Bw���<��%�sm[��V�hƽ�$��Be>�{�����㥥=2;�![�=�
>,.�bb�:$�ۻ(4>����q`u>�>˭��ef>����z>7�8�Ҟ�=)�����=`�=�"�_"�=��;�/F��ɚ>��b>�G=���=6�=��9;{�P����2��=�6g��3;�'��~�<������z���)� �뽈%��=�=���=u������=j�˽5��3��:����<��>���=�e=ꊵ=:3[�*t5��P �b`���>��d>���<d�n��g;=���:����p+U=��=fWX�d�>�(ϻ}U=ti�=��#��K��e��=��� ;�12=�4�;>�9���=
�=����K����� �=l�;���<�)���^�<���]���0ڼ-J&�A	���>>ia,���R9�=]p���׵=k�'��^��Tڽ�g�=F���ֽ�R��<G�=k�&>��ٽф�=C�x�H�=�5�=��$>��V��9��R>}�
��0�<E.�;�P���c.>!�>���<��'��S>-2�>�w���|
=QiY=��H=�:4�"b�=�a�=$�/y�=g��=�-z�r40���=�-�= �>��_>N��<���=(����W�;_D��n_�<x>o�
��"��I<�M����=Bw!>va=���;U9�|ę<���=�!���<�#)��>��<:y�=m�'=����d#��)>���=��=Xp�;|��� />�� =gy�=x�>�=��A>���Ӽv��
�=W}G=��'�<�<�[���C>�nG��C��DT��^�����<|k�碽�<������=dV�<��̼ڄ�=Oi�=B=������=��*>~#Q=˿<>�8	=�`=w�#>z�Ľ�.6>`�>���;⹽��=k�=t�E�z6�J��=�֜��9���p�=���=Eg�p�I=��>C�=��=�.;=vZ�<)���wi=z[=P6��`N;<.�<LA=��=�΀>�^��i�����>*�<Xx��Fo�����=|L�zL&=�>rS>BҼ�y1=Ч���J�=[馽>������=�(3��X����<IE�=�f��K�Ƚ�1u=$G��8�����#�������;��!�����̀=��=6��t,s�ڼ!>ŋt>b�~=>{;<V�ѽE2ӽ��n>0�����M��~T�b����)>�������>9$d<`s.<�5<�%'�K�=�=P�B<���c����L>!6>�I�<�6u���>d+>�g{�=b�߽�j<�X����6=Ⱦ���������>qǀ>��}��L<����b]=�4>�N��R�; @>����[o���v^���=�U��d�� y�;��������@�����=���s彁>�=�}��,c=M��<���<�B�<@��z�=݆
>а>t/>+=��>H�>�+�Z� <��>'�:>���<+K@>�a>���C>>�?�����A�=��s>{��=��>�������=��9�|)6>�t���$�<��9=���u�����A>lƏ>U�<���؝E=	W>�S$=���=��N�t�=7J�Z��>+�!=wR=iK�=�>�v��|v��͏=�!�=چ���s��H&>9(e�����阽�UF=O ��[�=��6�J<��=�;4�R��=P7!�"���?��=D�=Q��=]�K>��=AT�PÝ=}a��=2=l�w�����ν_ze�ި5�@%�=��X>鐵��<���m���[.��=\�;�k ��a�	<�=�#�=���j���*��N7�8�X�ˍ��|�n<O�*���=�e�✄�����ۑ�3��=/ϼ�M>���9��2�@�9��7��E��=`>oR�=��O=��p�ѩi>*ױ=��v���`�m�S���(�DI ���,>h I<� �ԼS=���}�=�N$�/3�=Ҋ\����<;�c��Z�=���Y�]���=�~�<cw�Ʌm��Z�m�����=���<S�8<��L�U�'=�h�ٯ$�֜���(��x�R>k�����<���l��2m�>yf=�gB>.��=&߹�D��<�=xB�=rF,>��6=��/�Pk>3o��?�S����=�M��xA?�1/�=k�۽���>ן�>܇ѽH�9�d���+=E�@��	/���Cq���̾�H�<��b=��c��ʺ��=�q.�
��=�I�<(`(��D�y���o�S?=0�;=�J��2=��)>�(>��~<p�=
KŽb�<o��4�[�Q������h�O�LԽ?�J�V�|�j�
�>yh4>8S��/nٻn�p��<wQc�$9�k+�=�A��T�<#D߽�p3�������=>�ӽ�������=�=qi�<�饼�'�<�=rM=�O�=���L��+�=��>��J�Y˼�P������`�=�<������� e�ç><'k�=���vX���9>���=���<��彞F�;ju����=��P=�B�#:^=4~�X�<��=4>nb,>�I�1;v=B=�_�=�"�������=��>w�=������䀨=.ﹽR��k�;��n�w�<���< �=ڃ]�:_��M��=ߔ0���>:먼_s����z��Z>�r�<Y��=#��=�%��	�<!�>(Z�5��<)ǽ�x$��F>���.���سy�6��=8�!�k��=r�0�C�E��Vн3��=U�&���t��<̆i���]<ր���F�h�=Ő�=�v���3>0�߁���V�>�6׽vt<T�q�'֢=�Խ<L�;����y��%�����<=۩��Q>ڥn�",����>�bK���y<q���`��=0g������Һ�����Y4���]D=:�ͽQ����v<D�aX�qm��
f���u�u�q=�0:���9�. ���a��j�U�ԙ<�Kż;�l����=����_�>�(`�<vQ۽v`>�D���y��j<�
��~����=Y���)�g��j=�>Ņ�qo�=Vo�=*�=r>�=�3��I[�gcy��(A��e2>!�(>쨽�.�=�X�U���!9��?7pl�=�z��N�(#��:�Z�̿����^1�<�+�=�>�c�=o_�=�@��<Y>F��H��<���P������=r�8���s��<"�����&�ͽ�}<z�=�}8=E�Ӽ��y�Nн��*���8�k6=��>kR5���T=�^�� B�<��I�=杽�L��)6����<�M�t9�=��|��桽���="!���@�G��=0��<~�	>��;�Z>L���H��:�2>i��$(l=��<c�=���=�~�L���U�4�w�{�gT�      1`>0�g�}�<lq�L��� �;pߚ=�>k>���=G>@;[�ཱུ1�=�W < A=��=y��
�c�@^=v��=�y�>2	�=˿�:�,���K`���,>�>}=�Kݽ�'��U�5<��>��	�dK��{�=G6��j��<�6H���p�=���=͘w:DM�:E�=��<E��H���{�
����=�Z�<�SH�)Օ�O��=(�@>E�-=����K�<ꭽ�c��S>Z;���=x���X�4�C>3�
����S����C�<0��=zĝ=�0��	�> ͽ�0��Ƽ�0��D��=� �=���=�����>7�=�۠��B�<$�6��+�XYE>�׽p˽�t�6�=B��=]�a>p�$�UɌ�w9��`��.*������b���=�� �\�(�>=�{>qg�xt��< ��Y�^=w'�<^#^=�Ʉ���<f	��s�&>��>�]�=]G�<�.��R�6��QB�=YJr=�hҽɆ���(���=��=�&�=��3>�I=�����>���=�霺e��<�ѡ=WK&�s�d>tt�>��ݽ�W���U��UW�Aeܽ@�%�����l=,�u=�/ν������������ψ�?n�󊿼��0���>�댽�G >aS�<�i��1����>o���d�'��W�=l"ڻ����%��=��̽d��y�����>9#�:�܀�=ƽ=���=��<�́���<ï�=���|߾=�>8��-���6	>��$͉=�$�0��=��2>��P��F����=�T��\C�������!=�����P1�=QfA�5�{�Nck>?�=re��&t�=�1���g&>�iw=��]��!<c����^� �Is���>�r>/����½�����h=�ҁ=�d=�j�8�>�70�1�C=�0��Ҋ�7����ȕ����>���y5�=x�!�O;�l����=�0�=�ǽQ��-+����X�V��[�>� �8ꚼ���'��z>�����tpp�n�<0�s��=&7��e>�@ν�W���=�!����,�U}��-P�Y�6>D�=���:ׯ�=	�#���>�����l?��3�����1 <N�=��>}tJ�G�=s���i����e=�O<>)�Խ�PY����>�u_=��w=bm�=�<����r��|� �۽�������1�jne>X1@>��0>��2�v��:��5�̙����K�>��t<,��=7y�=�#�X\��Gk<�����Ἑ�1>s=}�A=��3=����D�N>�2����;�>�pq=)�<<��~=r�=���=�ѧ<��R�A|&=Mo=ڋ �-��;�>qO�=�P�7d=�}>�������<�:�=�Ê��1�-�v���W���Ѽ%�7�	��=�7�=�V�^a���=>��J%=��	�y����w=��Fw=1>1� >�R�<�d�'F������H��@A��&�+�(�ʼ���Ꮂ��'2�*a2���6���0��[_<�T�=�\�=c�><�<1߄=E�I��Yl=�&>`k��5��=��d��o|�~�̼�$�<>m�<W]���� ��3̼�L>���5�b��,=> v/=|��=ާ>Ȉ:>u�=���<��{N�`*�G�0����=rq�����3_��l� ��x�y<m��[� �2>_��<`!>.� >�.�^鄽�+�=OX<STk���$�/Dн)G��7]$�ؼ���<XZ;>��=b`��E=�=�k�==sǽgM=�z�$���F'��]=�U�X]T��� �L���!��"��szJ���R�^��R��!轭�F=Ÿ�:2����!=��=��ƽ�h�=[ M��"�=�P���=�x��qC��ye>ia���g=sn@��B��>���3�@�w=J�]���d>3�=k�Ѽg"���X>h9�=z:�n^��W转F�> C����O=b
����3��s=\vJ�ї���/+>���=XF=;1!�j� >�Y!��Mֽ��/��<B�O=��=I�G�=99�=\Ž�;�=:�=Y|%��]��:>�JA;!>P>�h*��sQ�b�y�!Bz>b�G=���<*?�<�=�i��ԅ�o���^,�R����ͼ� >D����       �RľS��p5��k˾zqY�R��� ��!���b2������ӽ�����W��˾���>�s��{�?��;><�����       ��?��?@�?���?�@�?ڏ?�6@��?6�T?��?Zҫ?�0�? ,D@R
@���?���?�n@�u�?N��?�0@       �(�?�6o? j{?<��?���?��?kpg?[��?(��? Cf? �m?=b~?�k?��y?U�`?��s?4^Y?#�X?���?�W�?       �%             �%      @       �k��P�=�h^����='ѷ; i#�������<�==�^��轩�=Q ��#!4>�G>z����콵 >��=>2�=�{�=�����(=/Q>��<��=VɊ=U��UE=�/�=�#�=���V�	�4=�c����>�C�����߽�n���!w=�8G>�$>�ٽ��>ҋ�E;�=Y�R��\g<=��Z��;#
>ɽ��=L\���}<�M.>�#�>�N۽�O�=�f>I>�=` �=       JA<��;���=Q��=%�<1ʛ=��;�n�=�>��T�=f�=���={�;2�0<�u�>�0=؀��W��=��='֓<�Ï=�H��2~>vBg��̣�L6u�)1>���l��<�=@�=���=9~��AQ�;~�=��=T�����g>,�Ƚ�_�=С7�n.�;���>/��=��=?�=�\�=eZ�=OX�=����i=�I�=i�<>���W
>��߽��=�3=�_o�St�|E=��R�q�
�Jxq��aU>�I,�5�=e;����=�ߖ�<	�=�yd�Mܵ��n2>��[�x�⽽�;�9�����<�7'�]�r�.�>b�$�D�=�
=��#� �'���E��i�˼BA�b�ؽK��<8�>�dk>ǘF�'7�<$���y��{�E��=�SB>?�ռ&�g���=z?+>��ٜܽ�<_L�<�;6>4�e�P=�浼��Q=�=��=��!>��?=�A�=,�>�	��f�>��>;���w1#�z�f=�Z����=���=¦�=��2�P[<=_/��r�����#�t7��)M>�><�	��Z�=��f�9��/)�c��W>��#��v���Y��䒾"�=�3���S<�T�<x��z���b=V�G���m�7��=5�Ͻ�8~�Q����T=�g;�6��8o=�ܻ�&�=%� ��7�=F�K=X�m�e�����:�
���B���׽����������D�=m=�c���ڸ<��@=3l=-�E��^��aL�N��8C��
�㼇>�eG=�齾�����F��避���<���Rz�<���}�<���뀎:KF��,~$=��u=�ߖ�����8�=�_J�Xa�<����51<q)�`���؀<%�A=ɡ�;�4ݻ6 �cl�=Ũ9� �ݼޔȼ����J<a-��Pj=�BY<y����U=�vy���X��{��>�W=)b�=h�>i�2��p<>,s	>��>'��=�Ǝ=F;�=49�=�1νA�>��y=j��=���yv��;�=i�<��<��V�;�݉=���=���x6���U�=)�=����q~x�	ԥ=��<�_}<UA�=��=$�E=�#޼���<��7�V	��Ӻ�=�:�=���u�-=f%n<%=�C��I�?>�jû��8>9 >{Y�;9�����=�ػ��W>	����3&>�製v��=�믻�6c>R\$��a=�k=Gk�>]=�B��>x�y�x|�=V6>���<N��=l�B<&�<�y�<L_>}�=��ف�={a���y�<-Ъ�% �w�=��F>]��<����#�<Ī!�.�">]X ;�ĸ���=,�0=�b�>�=��0>Ot���������8>���=oM̽&h�廃|j�����������������轕f(=����V���7�T��= 4�=s�>N~=���$^>_p��F�;�N>1�J=Ǥ��Q�� �F��;�]=��)��[9�&{<�CF<5�;N��z\����:�f=@��=�02��ty��w��L��8��=�0�=��=��#>��E=K#����<��>�����f_������R7>�ܽ
�b�O��{��<���ҿ;-���?�<M�+�HNb�_Pp>��?�|�ϼo��=0ާ=>c��/a�+��=��D>"X>�>�55��)м�J=�����B>1 �>���=�~=�:>^�:>��=�Y���j<3P:=�	=D�
�E�<�L�=�=��_c������~��=��B�hj�����:����RI=�I>46��=M!��Y����>�ս`E>�4G<A��K�x=l���s���&n=e��I��3 �,��<�He<��v��������o������O�Z`��m����(�?�i=��>a�)��c7���X��;�<>Ǧ ���>6�<nܼW����>ɖ�bwr>�y�=8<l=�	=�SȽl��=	:���J=��佞��=���nc�<D=�~sC��p��x��	�'><����=3q#�+�0>�0�<
�Z=���<�S>#�����j��P�=%��=Kt �Qj�X(�=��<k�o=u*�=ϊ	�q׽�=u��<�1$�SA齵��=�����<�;>�&�=0W$>�hk=�6�>(�J��$>�W1<����.�<ZL�=�*��=�}��z;���1�@�=P氽rչ<rV�=~"Žp$�k�C�>Xp���5�=�z~=�h��F%>t�(=m�6>��߽p�\�#�=�h=���>>}�<�Ȟ=o������h=b �$j�#t%�q!�=0\I>�p�k=0=d	b<(a�B�>	�u�@^=�Q>���=1Y1�sG̼�C>��=�r-�����A�=O�9<�y߽nz����=K�=���=�˱��iٽ�9����C:ݼ>B@:pظ<{I�{���I���v��vӼ�=�
�+�=�<��=��=:�=[�`=�c�>j�^=��>�P>=�Y�W=d^>B.`��#T=>5����d>��j=��<\]�<�=.)=�<pϥ=��n�ƕ�=���:]�=�>����=������>=�!=�k�<:Ŝ=���=�H>�
=�L#=<�!�l�Z=��<�ͼjH�=N�L<��|<���>��<�K�nv���[��>������=�c��bd�a`��S(Q�CZ<�O>3�=�/�=�?=K|�<���|>���<^=tZ:��S��
2=K�Z��>0;C��.�;p�O�����[J_�s�i=�5>�O�<��0��������彯��߯���5�=�=��=��,>�I>��>���B��`5>7To���=*�Z>�=�
?=���+�=�S_=�������u>^l����Z�)��="a����ܽe?��+�-�ZXS>���1ܼMo�<Ĭ���Ԍ>jB��~;<�ˁ=UֽA���	l���{u�>� =T� >��-��_���=�q���Θ�~R<��=#�<�}��osw>�u�]��=�s#>Ye>���<׀���>}/��d#�>�g�=�n>:��&>V�߽���h&����R>yb�
�н��(�Q��=�i;���L��.�<Ӆ>ׅ����<F���bX
�����p~C=��";mn�=��>=h�<p%s����=���<�#��ߧ�A�]=2��=�!��
���c�P�G�v����G�=g�H>��K=|��B(>-�<�S->/��=��=/2>u�%�[	�=ɹ�w�O<!X)<m��*X>�tX=���=�R=�j�=�y>��Y>x��g�=�9�<�n =���=<�>�dɽ;Q=�>������0>�D�<����М׽����7�<�!�~$���
���=��9<�Y=� >^�Ľ�Iq=�娼&??=�kƽ`�=�BS"=�%r=qw�=��>�X˼[��=WS��0�=�8�;�튼�\�<CkڽYڝ�\CZ�̐=���=� �=F\T�[x���=6�A��u6> �̽�Y=�fU=��彦z5>ϣҽ=�_��m��8>h�S�ڢ�!�=����]!��½�PZ�(��>U(>ٕ=<F¼�:��# ���F��:u��p����ܽ�S�=F�w<��=��{=�(����=o��=yEA�ݑ7��W罰
>�~`�oY�<S��=���=�4!>\w"�+h>�x=�� >T�ͽ�>��=efo���k>�w6���=8�1�p
��z���w��1m.;;o�<у7�H��=�o ��Y��7M<��������ݖ�S������=�r�>�=>�9�>T�����=j=� j=�P�=��ݽW��=��=�,	<~S�!@��ŕ�04��򳽇o��G��=J?�=}|G� 5��~v��B�ؽM���� �j��=���:��I=��%�9c�Xn>T�=�#<@T���F�o��񈽡�=R�ƼO�)=���a#>XZ�<d�d>wv �7�k=G�������LŽg��=������/��" =�e����=�d>?@><�!�F*�<Sv�z��Q�����(����m�=��7��!w4��2�=Ѝ�*�A>���H_�����<~)��/��������R#�D�x�Q�D���'�گ�=����'=�\�=�N�&>h�=�� >i��Rg�=�RA���3���=�e� <|����ޣ=z恽(��;_��߽�rV�Gݽ�,���hP�ݕ`=Q�޽F�꾗8C���½�aV�J�޽-h{��rŽ�X�����t �={~��	���	�IՎ<4�S��^���,�]=�I�=��=�6?�|_7<��>���>:�>�)>^>/��=����_$Z��4輵����jT��+=d%=B����� ���:����,����a��c@��Aj�XA���<Q���<�=T��\-H�'�/;��>H/�>�y�=S�k>��>��=ͣƽt �=VB��[����=ۺQ=%�>��=XS>c>2>m楽ؽ�o�>�PC�>��������C�Ņ1��D��w�i��g�>���ύ���(�}��>���>u�[</h�i��7�$�X��yHD=:�J����h�;����ȹ���i<W�cX ��!�7&��I�Q[n<�oc�%{����=���>E������=�!�J5]=俏=t�?�ZD<��ټT]>;���KK���(��SB>okj�yB���ع���.��:��_�<gU���>@嬽g:���0e�%
7��탾��<��^>�J>O���Wʃ<��ͽ��>��¾V��Y�hd�0ּ� �<^�<��=��l�h�A�I�<�%��t�	��R<�h�;%�=�BD=�q�:W"�=�n��Y��<��;<yR�9�;��5���@�$>����謥=fEd=�C��6q=R��<��m<ڟ�=�U<��ս('= |�=�Mv���=�<��e]��������m=�鶽�j	�I��.N�x���I����g=�m�0�\����̽�q轒�ʽWrc;�&�������+��#(���v�Ϻ���ʁ=SpսNj��M �%�8���zU����=�;�;����V�:� �='���&x��
�=`m��n�Hz<w��=�Pf���������<�����=H��<�.z���ڽ�Ǣ���;>h�=���m��=����W���.=�μyă=NZؼek�<�=��=3q�=��=��<d:Dx:>W�X<Yx�;#_�<�:>���=��>��=>�=6R���T<O�?=�o><f[=�份�����ɼ=Ǽ/��if�=($��b�<�����=���_\=﹌��s��c���0+>p�>Zn�(�?������<-�2>[A>�H�5>����3�=��ż#(�=�澽���̽Rv���a=WH�=]��q&����=���9���=��%�5?�l	�=�U�=�|K>���xa�<R���[�>�c��l��:S�:[)/���l�U��< A�=W��=Ŷ=8�@�K���I�>o"!=,�Ľ�������َ��U ���V���u��=��E�od�=�@:�񃥽�2�"	Ѽ����\������tw���>5�a��M>�T>�(R�O-�=Ŋo=�%�=�>�w�=�����Ę=_ϸ;�v�=�Ss�x	=U��<#�:=I(򽎈y=�ـ�V�W����]b�=	놽ۈ �'�R��J=��g�?�un,>�>>κ�����?`Ƚb�w��	3�G<�<(Me��6R�l9D��B����D=�y
�bi��H�<�j����=K�t��{�!<M��=��=����d�<vNA>�SڼH0�<�6=h��:�K�j�7��=�Ny�\;�=�/==2�>�S��	�=�>n=;8>[�r�3my�aʽ���=�I>T=$=�֝=I�!>qI=%|<��=�du���>�)=P�d�KUٽ�)�}N���ks�7��=T�h���O��>>�PԼut��6�����=e�M�/���犋<�\S�K��<�?�ai��͠B>c�6�ѷI��{�N�	��ԗ=�=�=�Ж=�o�=�=���Ұx=�� <�n>�zJ>V��<�b>1�=�#���ؽRP�=�~�X�>;�h<~�+=,]*����=��=z^F>@�ǽ�;>vm켵�����#�W<�=/-�=�Z%=ݖ�=�e�=R�=�(>k0>�����Y1��c�=M$=���=\�=Y7���V��i� >�׽��; D�=d�	�(`�=.-}�OR�<-���p*=Mx6�,q��J��>��=VU>A��#ݞ=��=i1M>%�ټ��*=YX;��9�!r���X��>qd�;�!½3�+<��=7>S>����d�>3a���;{t=�Mb�]��>2j!���=�C��Ȍ=$u�<���G�=ڀ潓�˽i=b�=�Cs>$z��Ft<�;��'�l�=I�����Y=N��=�<K�4}˽�4���8�@�<Md�f�����r����ñ��	A�+v�<�H�8q��W*��3>^����-<� <���F����h�]��=�n�=�i�=�(;=qֽBj)=&�I=�6U=^fu=��4=Dj��8v��ǔF>H��<��������S�=ӹ��GO=r�k�퍪�$h���=�'�"���p=|���V�<v�y���<�Gi>��=ss��d���:����*>L���=������ýVa>�e׻��r�q�	�NA��.P����<#���t�SͰ�^��-[��4g�<�I�=�ɵ;$�<=A�<����K)��;M�	��R#=�w������=�6oe�F�&<�93��:�<RZ���	���Ӎ�_�����\=l�Z;��=oe��r=-���lK<���="񼙢�=Ғ����	����;L��#$=Jf������ٺ�mM���~�>u�=�0=:�+<&���Z���l�<q�s�K�x=���򼧽gA�G25=�&���C�� ?{��=�������1=aTr�?�=v��L�|�D���O���gJ��Q���X;�ʭ<����C�*����*`-=39$�62�=u�<����̽2_���X�=oC�<���$>C�����F>���4�򻓂j<L+�	On����=��=uv�Ⱦ�U�0��s>v�=�RO��B̽R>Ӊ�<ȱ�� #o���=�h!>�A�<��N>�I=��)�d���� ý�W����J=�A��F�E��!誽�΍��+=�5�<�5�������V�=�w��9�<��Y��8x<4ⶼ����Z��@�E�NC6�Wi��
=� �<eh�=���ڊ���CѼ�i众7��G�=jS�s\�=uā�\���`��>���=�������=�J�=�=����H ý�L�=ت���9��kL=	o��p�	�����R��X�=�[��C3<�#�=B��=��>gS���^;SF��4�=��H������S��f�i�������t=#=��
>��;��)�82�I��==��:�Ģ��W=��>f�c>��>�>ċ�>� =��>�*�=|��=�	�=��J�*�!=Zs����;�N%�ңm���½�:�M��TT�=i�,�暶�U�y�^ǽ�˳<���r�����k�Xs�e-%>+�r>�b�<N�S=�Y��T���yjg���D����<�!�R���fͽ�;�0��-�>Hw=nr���f>n���;=�}x�=,��=T��=5@v�Ѵ6>�>�>}�=P�>A�=�g��e����=�n=�e�T��V"��UH)>��y�������0>��7>�~��{�����V&>����t��<�3�>?0�=��=�"N>Sڇ=��e=l��=�0�=rJk>G{t>�<_$
>��A>�I�=m�=iƽ�>-��=�d�� �=���=���=a��Jg�3#>�2�=�O�����('�<���=v{�=��<1�+�sy!>R����=@Ҵ=�p�=^l�=�]����=��=���=�Fɽ�7��E�`>Mc�ᄙ=��Ƚ�m>u>nC�=匧�2@$<�-��� =�l���'��c>|w+=\M�=��E<:���j�n>�A�;'�:�EA�>�3�=�$�<���>4o>��8>~�>Kx���&=Ho&>k�
>@����%>/��<*]�z38=�ur�Y�g<H�O>x�C�==c��������=|V{=�;9d�S���=t��<��>!�<�"��l�>�_��;���c=PȀ���=,d�|��KhG>�ܻo�Z<�ǃ���,Ri�+�=��<x/>'�<���=I��<!�">(FS<��h=��;g�=��νo{ɻ�v���=�'+�@�X=�[�<ǠP�ng� �K=+=8��;�P:�!�1=v��x̕=,1=}!�=�N�9�t>4�y����=����ǔj�)x���k�<|��='<��Z�Q�g=�ƼN�>����o�=�{O=,�<��\��<�=�#���
=ev�=���=a&>���=�j=�ѽT��=RO�<n��=���;�A�t,1>i@ʽ=�j�	�#��S ����Ƭ�<�L�=t� >��@�*ղ=wz����!��s���Ѽ�=NW5�����G]�=�i/>��<�����=��t=���=y�o����<��;I�r�A�,h�Z�Q<�󏽞����=��a�Yf|�S(=f��`o�>Ή⽙����2���9��<�)����Jҽ�޽�.�=ʦ�= �=�̶=2v<���=�ڽ�z�>�J�=��$=S�.=�U>�ܵ='�d�ym��$��<�2ʽB��LМ������%0�DÒ�݈@�KL��!"���):�m���.��V'���#����=!���!�A=	f=���������,��]�'=4M�����=7(	=�	��wG������<�»����:�c3I<�U%�Z��g�=������<�Ͻ�輹e������Qč=fY��?�=��=R�<�dN>�o2�ֹ�:"b�>:��=_�x<����������a�C�i=�'�X\>��=^˛=M$�=�	�=�-�>Hȓ=@��=�M�Jy=<��/�Y=�m�=7=�$轤�1�9�h=�-'�j~��:�� 9��	}��?�5�<�E<!�S�:�ܼ �=:-�=�%g�A�L;�3�=�w�;jȢ>�S�����`>�:>>f���u>=�9>�~�=ؗl�x����=a��<�-:�"Q!<�X�=C�%=��=�A��N<���P=��(����=��<O���[��jS=ɽ�=��g�nr��@�g�p�H-�Az��y��=�k=���=��F���ߺ_��*:�U�><'�
>M��'���;�;�G�=��x��+=(mѽ;(i=r���OJ<�>�<�=�E���qͼ)�=�F�=��c����ld?�~��=b���=���-�=ߠ^> ���fJ���	>+ �=	�����	>εd=U�=���=��i��½s=�g:��۽��>Մv���f�פ߽㼫=g��# ���=A�>���=`� <��#���T=>�����7��>��>�	�R	k=0�>�X��=�=>N>LR�<��="͌=[�`<@Ʊ�mQ2��O�������<
Q�=�P0=
�%;_�=湭���=հ޽�;��X��4�t=��>���*Qg��>(>Z����=���<�@w�hB����>����G��=��>Ŷ�=�KG�M�o=d�< ҍ=em��Qė=��}>Ky=6�<D5=|��=?~�P��b�\>=���=� 껀o>�=LC��u>$�_=��;^��Fix�Lx(>��`�0>䥷�hմ<}pF�c�=lf�<b=��ֹ4��=c*���@Ľۨ��&.{�[b=W+_=�g0>=�=/l=��	=CW]=�I�g�+�˾\=�΍=)�<�y=H޽���=�m��6�a��4@>EQ>�it�4e��\���=�=>4�:=��>D\����M=��=��b<G��=��=���=��z;�+���z>��=�v<_�=��>^+>��+�Ks =}IJ=.B>�i�=��*=_�>�z9>L�>�ʯ��T>�����,�<�x���Q���ܼ��(=��=�A�\�R�V\��'�;�Ѵ�={�7�߷��!��,5>ܙ=C=�>�*>�d�=&{m�OƽV�>�A=��=��,=}0>��=j��=�l���p% �e�=�
�=7�+��6>��=��~<�>�'=�䊽��.���=���<\�)=�=�e<�/V��6��։��P�	>/(�=�����V����;=�:�l��<���=d�<@V=zK��1��=�� >����h�=?�ӽٴU<C�<���;�^|=l>�<�Ŗ=�1�<?pW�#6>NNt����=��E���'=�>� =�W+�P�ҽ���u"F=^������Hq�=�r��_d=]��瞼xjb=���9�>2��=��>�=-�>=æ=��=�����>��W=��@=%Y�1 >�bS=���;��[;i�4�P ����EY=6��=�W��a�2���=X�Y>^�><�n�;87�;���=/���J��=[�Y<h�)=͗�=�q@���>�*����=	i�<_jS��m=sn�=����``>�zW=�ݬ��sk�߮�������=n9��VP�����=Z���J =?���I���ᖼ����2h<�����ɼ�G+��d>0�=��k����0<�Tn=O\ѽT�k>�I�!c����������C�}�==L�=�!�<Ԝ�=�=���=-�0��?�p�����>���R*	=V��=J7�<}�=�/�=I>}=���=9�;l��<�u�=h%��!�>9S@>�6s�Q�>R^>�G�>>��=�=f.���l�=�վ<TЀ<q;G=�c� m�<`���ܱ=
�8=����*�=O��=�-�A�m��=w�%=��<2Q�=�D�<o	��Qu�������=+o >'X�;*��<��=!a�=�Mػ_@]�FMg=��=ƽ��^����=3꼌�ؼ���<�3��m�T=��>�A���<|�6���ͼ+�����>�*������=e8<�s@�u�Ƚ�<k�(-��:��=�_�<���=b�>�ۼ��<���=mn=�=T��=޻*�9y��G5�[>=�o[<��}=@vr�d>��;�6��k%�=fd=0s4����<^��=W�=�쒽?{b=Ս��(�<��S�h>8#=؏�=�{ؽ���=9F<>90;Pf.=�p>ߎ�=��=�1=D�x=�?=Nj�w2
�0>]���G>�5g<����ᔼ�,�MW��?֝��aܽ�w�=1]�@1>FX�<ҫ�=������d���/>@�u>�]��WՍ=��y=6�#>Mz����+>k�l=kY�=ٖ>�1=��߼�ѹ��ސ�5�y=;h��E2��s�>�b���<?,i��OC�j����-d�g->�,<f>��
����=�z>Ռ�2�=T��Ž��{�:>%����=��d�w��::�^���!=��	�=$�=��Q=�?�=N~�=���~�F=�uB=$�>D�=�2���n=�i=＠:���h����;��4�m<���H�>,��=&��	 �<Gl�=��!>��=�#=Q>�4�=�����6*>6�|>½�< �=Z��_O=�=���,o����#V+=P�߽�
�=ǃ/�L�]�֟=a��`?�<�!��Êi�I�<�m>��=�>gX�=�}�=��>7C�_�E���0>]">���=�)�=V�<)e�=�bH��l��ɫ��)6��K�=ﺭ=�}>��}=@T>��_�=�ץ��R�=��ͽRW�=�71>4��=z��zN�3�X=��9�s�=��Ϻ�sR;�_�=��<Om�<v+x=�v�:�B>j�u�=��Z�x�v�E<���<2m��+��P����i�:Om��+M�=g[�����[k�#&Ͻ�
�<�e>���g�M��<1��b��rμ�~`=b[�=�#F=и��1)*�{�O��Nؽ��ٽ������>9��R�->b�=x&	>��v=�&���ޢ<��T=nj<:�>�*<��C>�jU=��g=���=�.Z�nV7>exE=�D	=fd|��%սَ>��໨ҙ=|�F>�Z
��M�=6=9� >q�޽Wc�%N0�l��i�3>�;�cb�=�顽->������Ȑ�i��=̷�={нh�O>PM&=�����K0><wq<l���5i��'��Ԗ=���>�s.�R��=͓B�%y-���<Ɯ��E�m=��>��=�H������ф>L�ν���\B�I��>)�ֽg�<���% �<� �6��r�R��-�j�#=h�3�L@L>D]���={�=Z½��=���:q�={t8>�I�=�#[<�a�F�;���>?߼P&z; �v=�`!�1 F��g�H����=d0<������%�[=#�=/祼_ԽV�=�{�<���.���	>ض�=���ms�=�	�=�>#��+=���=v�=iO��q�!��°<Od�'P��i
�<*ٽO<�;8��=�8� :�=�r�����|��ǽ��=�=�����=p>��=�@s=r<��uZ�=�B�=�󤼻y���%>k�N���=O(�=�|=0f=D�	=Eus=׫�<9Hb�V	/����=Sgw��]����D�o�����D���<��i=p��=�}>=�+�=<5�����p8C�ސ��|��=Ң��!�<�T!;}*�<s=����	>����^�a�>�~��=Bv���͝=fY;Qr�;�6��p��q��<��=�/ >S�[��=�:>՘���T�<�af<�4�=�<U��<Q��<�z>�o=�ܕ��_�|U>��c=C>Z��=�ȼ�8=��c=W}G>�"�;��<�>>#�<�a=yO�=X��=�O�=܄ݺ}+=Ѝp>��=��>%˅�I��<��漿&=%��=C6U=�@-�]�E���1�%�;=���6-p=Z�p��I�n�=�������<#�G�9<Dh�=�<{��=�Ǽ��=�K>Ft�=�~�����=𗼑`�=֥<�d���(�� {=ҳ5=�iq=�-���N>ac =�<V��.@����=ٯ$�b���L����<WA&�{�����=Բ:_
2�v��d�=���A�|�����<�W
>>����G��2
��KG�~[=�e����<lp�<'�!@�=��μ.���%�<�5��nq׽���K���5�=���a�9?��4�="�=����ksa=�L����=H�H<���=��½jC��=�>�͕�T�V�30=��H9|=>�<���7=ר�=r��ؕ۽�ż��*���S=E���Vt��t���>0��=9���T�@{=� =w;��t��~2����t�@��<S��=�.�=B�>�猽���������@>�սh�U<A�мh� <��,�'�н�7>v��=N��A�>����,=���=�U��e�qď��i.��3�;�ص�m&:����͐�;??P�y�>t���Bn��}J=F$Z>���0�ܼ�=�6r�5L��`��ba>�_>J;$>+>e)�=/Wʽ���=86�=��=�cN=��ü\�>���}�C���W���.=Y=>_�,>�u�������f%�H	=a���="�>N�==:+��<g�#��=4iŽ���=��h=���<}m�=�K�D$�=�D��p�=��<_[=��rG<>�V=��Q��ǽ%�,=4�-����Ah3�LW��G0>O*}�霑��9�,f������.�=#���;���kC��,=�s �
�=~-
=����Q���(�X>�c=��Y��!�\.B>Լ��{�"��7I>�β��F����=oji=�w�����=�>SO>��=6Tl�
=a̽]6�D�J=�@P�� |�^�����=6&���@=���=�]@=���|�=G�]�=�;fP�����<x��]�=�������5�<�W>5���-��>G�	����=�Y=�	�f涽��<!U�=��=�9=^�= G�=B
>��=-�I=D��<��2=��:ړ�=�@=
ϑ��b=�`�<b��Ű�=���;���[ `�����,n>��@=�"�=�3q��\�#�>�_>o�G=�O==���=��=�\6�A90=ruK=��=k2����=��=�~�=c�*������⽶������=��=�l����M�)���*����=m]d��$Z���*>���=fo2>�V�O�#>��>�Y�t*��S� >�s7<��=��=�:<>��<u���o�=�Sr�$�<�`Ľ���=���=V�=Q(�<�e=�i2>l>B>�2�u����
�;y?�=���<�e%=�6�=r�;��F=G��;��8�w�<�?��� ��j��=����T�6>�8�<b(<�a�<|<9�&����=A���������Y�
��=��f�8=�d:�� =��㼵亽�f��a�=��0:%�{<a��:&�<0"����=�wP:�>ݱ��\�)�R�>��l�Wn�=����Ѱ<?<�=�:`�>��Ƽ�k4=�|�B�>#M<�w�=�禼n�>/��=�X�̉��[�=�=�W<r���٫(>�>=�>�=U��~cI��λ���ۡ�=����;;��=�s1�������=�Rc�F�<EV=Ⱥ=��:>m0�jhŽ��F=�u�=�L8>�6�<q�'>t5�=�u5���>0˽�O�=�U�=�v۽J��=gj�=�V=�x
=sW�=44����>�lD��<�E">�*�ƫ<Wb�=x���]]=䓽-.O��f�>J��=����ES%������R�(��k�<��ҽ�O�=?��><�<�`=�]9�XJR��4`<�O�< ��=��*��>�<�ڙ�B�=5���Q�=Smݼڷ���ŋ�}�B>��i�l�=�5R��4K�B�����O�<�����#��J<�������>~�R<~��i� �0�����>'\��/�M��xh=��/��(>�\��o��<:J�0��P�<��	>�B�=De�=��2�������;?P-���=>�2=^3�=q����;�(K�=�2>N�5��m��+M>iuμT2Y��,��TG>E^�=]�=x���>��<{,��,zA�L�=q�b��ؽ�.=|�.=���=ԕ��k0�i�>�Ǜ��u>���=��>�=*�A=;��=Ҧ�=�R<lF=e�>��,���<(��<ɤ�=R_!�����a����0�=;ZV���=Q�X�3�����$�N��=���=�Ǽ=��=0���2>;V=���=>���[�=b�}�=0��(>�sQ=��˼�O>�>��ƽQCJ=��<��+>Q�>�U� ��f?N�o�q���=ێ>M>��{=m�=��f>�"><��=_;`<��=㊁;�<���=���<1uX���<7��<@��zG��π=�Zr�,�)�t�����>�UH��e��Ffý���:c�=�#���T;�
�<Y>S6N���>������=�}�=p>=���=����W$<���=R��F6�< ���7f<�j&�2 d=���=A��=	k�=MOýå�=�t�<��>A�>h<=��
>����`=��J��b����=�J��"�=�����=�X=+�)<��R=�v>>�h
������,���^l�p��3���W��؋>��νy��|�=�B=0a�=
�D��=AC�=��>���='1=�MX>5:�=z��=�	N= y=J����^�F�<8Qּ��>���œ�=�Z��ֆ=jz�3G=��=gK�<vZ��ֱF�#=:p�ց��>�>��,�K�<�?A��De<Ʈ	=P[����=dx�=��獘���w��Խ��>$��U'��@\>��ۼ1v����<4��=	P ���=��U���/>�=t��|H�'�����;	d���B�S�����;x�=x���f�����=_j߼���3 ]=����Q�-�)��<�A�=�3tĽ��e��I=�dν���Ⱜ=�G��q]�|������+9��~M��:ýQ(��	-:-p���=�2�}���VH�]]�<D߽ �����˽X'E��i��p�1l����=F쿼3�<[��=7�=���=�" �u�=�����z�h�:�77=B��n;��R�I���d��=�����x�y�8�� �v�y�=)����½��C�h�Z=A0 �������=�w����<Ml>�=�=�����y��cB��?��:���f�>�ם<ttd=��=�"�h�=;�Ձ=�ܹ=n"S9<�=��ýǼF=IՂ=�Hǽ���j>+=@�U�Q�V��@>�>�=��Y��Y�<��	�0����ޥ<���K�)>�Z<)&���&�ғ�J��a7����l�������=񳃽qK�=�= ���3��j	��,>���<l">�L��8ε= >]�ҼVU�=t�(=8�x=ur�������}�=��o��kT��e֨=T���j.=�Sd=���=�D�3��<�>�g=�Bѽ6�*�� ��0�=!�=*d��>!>Im���=G)=�>��=P`��Mr߽A��m
>�к<���=��<��^>FW=�%>�|�[-�����r>�<\V==Z�$>��<�C��0(�=�Ỽ��5=������&�ºH��A���C�=RzX��/��TX�=�@���f>��s=8�=>>�=/>X	>�6=>��)=����Ɇ�;#	�ĮB=A�=@>����O�`���إ�=�L2=MTD>��p�3e��Y@0�`Ͻ�����;L���rC'=�=,>��d�6�Ƀ�=���=�Ԛ=6轶�r>f7�<@��N���=9����=o5�=���=�
�<��;���&�!��=Nh�/z=:�\<�,�=��=��ݠ��c�ż��KY��ڴ�Q~>uD>m)b>��`<d��=l����jE>�x]�e��=Ѡ'=���=��j<��=^>�>��.�i��=}>��T=���lԺ��4=O�<�=f�=f�=l�E�5& ��"�<��=:ɗ��&�<�O>X��=�_>��=��=��>��;��=/_�=��=4�2>]�=��Y=Q�T>���=o;	��qkνOK?<H��=	�;��=A�>@�y=��H>`�A=��r9�B�<���=���=o4+>Aq�=dZQ=�f�=��;>-���;T>i��*!����=A�=_���Q	v=i�����E�Uҽ_��<w��7�Q�Q��<r��yޅ���~=�"	���.������8>�>�<u�	����n>_-�<���I	�=V��<B�aҺ�x�(���U�=�"�=���=���?��<��0;$�v<����~���k�j���P�=�L�R �<e�f><1m<��i=�!>Qۨ���>��=U���|�r>��&��l��/b=k.>5��:��(>���=Y�k=t�N�->��<ɋs�����G(��r��!Z"���=\rN�����_=gTE���۽+П���={��=�����=�VƼ&.N<����>�=wʽ���=���<z��=!d4=�+�=�_���G<��E��[<=ѷ=1@>-� 
���)����/=9�K=�A>^X�5RU��S�<p.<&:�̰�������Ƚ��<i,#����;3�=�������M�a<����[y���R�=�=��]<������{N�=$��=pV����>м�=o��=4Ժ;VZʽ�7�=Z��=��	=�%7�������%�o֏���5�Nw:=|���8��Q
�(N�<�����\�=�e#��������=��b��o='���>��|����=�|�=��>Č>�]G={�!>��;��9>랖=�*�=d6��8���"�c\�y�4>@G�=���T�ǽm ؽ�{<k����T�<n:�=�>�H�= r>��>��N�T�	���X�lW��
>���=��<NǴ=��̽H�=ՠ5='���g$����=n�`>��=к�=�볼�l>�/����>�� =+9�<�����B�=����D�(>��1����=�!>�L�<pp�<[�(>��0>`D!>�
:�$�=6��*=��@=~�>;�	���=>3��5O'=�%M�@��y�<F�q=0R.=ɫ��	�����=]Kj�m�[=��+1�=�����r(>N��=���H$=Y@?=��=�D�=ϡ�=��&=����=��=<H9>P������=cO�AD�<hrR='�
��^<G4�=��=�r��3=�������,�۽�G���/Q=Ws<�AH��/ݽЂ��[=�͖���f=�t�<B$�=a��=y��=��>����������=����m�=̀��H��>�e$>F =��K;���uu1>�;������M>m��<⇿<���=�g�=O�>�@ѽWY���C.�xW�>�\�=�c���x>G�<!�����޼�/�<�o=z%�;½�僾_��;z�Z=��4�̬E�h��%�X=��<}W��)���"��� ��@�=Q�
�Y�����#ӽ�Ǫ��i��#.�=��ȽU��}�lL���U>~M�����l=����2(�?>�&D=���>�|�+G>]+׽&u�i%��˫�=V;�ȹ=��=\J
>C�3d>I�5޿����<vu�������=����^<4ýzB=�Ŏ�ؕ>���=?��=Dgv>;`4?��>`�����<ta>���>�*]��Pn���kq����<VA����o>��=sB���ts�j뜽c8=7�����<��὿���k�<4�R��~j��~��JL<A� �{�z=1"�<=�5�0�=a��<�����e'��h���o�<4���	��r��^�=ty<2)=�7ν������tذ=愿=��<|��s��O/�<34=HF����J�R<�TٽJ���w��Y`����<��:�IQ�֜�=6#佑
�	O0<��<��=���<d2�=C����My=
_��u���n�p�=j�k=o������M�=ge��U�=Iܾ�BVŽe���^��%Oؽ:ͽ&�`<��޽e����7�5��<���z>ZE�F�>̅�=�.>D�m����<T	��a>�=��u>���z�t�/�ɽnV�)��<�]�=.�=䫪�%A�<��j<�S>��׽	����<Emk<�`�:��J�'>9E�=��Ǽ;��<���m[��J�=�U(��,�p3式�%�!�s���=zM�R�q����=?üC9>���=v�,>�$,=�>�X�='��=i(8=HG=r�6�VR�>��=��>�v�=�a�=U} �%�=>�>^���H�P>b��=jk	>!G�=��=���>��=� �=&֕�̝=$�>�Y�<��>j����OuL�'��<�r{>�h�:�6%�P�:������ ���=��*>$_��\���ϼ�1|>�����g=�;��+a�s�5=Θ��СC��6�/�!���f<��нyǼ�?�׽�m��y&��n��4=����/
�2�/=��>��>[j�>��\>9�>���<4��=6�A<���=Ū)�k�=MDU>*�5}#���⽿X�>숽;fg���ｙ�轸�	�C�R�ɄH�*8>��&�<��ѽ�@�=��C�Wkg>DY>�'I>�>�h >�ӽ97>$��=MY	�_��:T<��	��~z=�e=^��G=pbܽ<o><�(�U�s>ɂ�=�I�=��$��P�=��<�k>�a!�5��=���=d�E=?5=������=���=3�>������=��P�d�!�*SE��}�8�2=��8=��c�DSF>�P���q=S�1�=� >j��<x&ʽ��A<�E�=w
�<s����,�<K�=�v\=�D�#�=�c'=�G��9>6	�=�>�=d=�_�:�\z<�@�=}3u=F�>�W>��*>zR�= �<�2�[�1>F����)>�B>pG�=:3��Ȧ >T|�<6�!><�=��=��=�g��S<��=
S�=�O
��=*Y���#(=���B���߼�f�=]�>=�>�= 
�=��W�hq��o���ڗH>�L/�����)��'��=�E=� E>��=ߦ�;f\Y��#7>a�=�����(�:��>�P=�=C>��1>m��=����=�	!>�=��m=�=�y�Nk=U��=,�q=�`��]<F�n���������$<U�<A>���=�>Ke+=�_=5UͽEPY���K=g�>��=�t=֭�u�=)�M�2�y=lɏ�&
�<�|o����?q�G�=�*
=7P�<j��D%�jǵ��I1>�	���>�=���=JO�<